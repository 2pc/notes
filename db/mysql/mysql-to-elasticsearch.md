####  go-mysql-elasticsearch

1.  必须有pk字段


 全量初始化+binlog增量源码

```
//canal.go
func (c *Canal) run() error {
	defer func() {
		c.wg.Done()
		c.cancel()
	}()

	err := c.tryDump()//全量初始化，mysqldump导出
	close(c.dumpDoneCh)

	if err != nil {
		log.Errorf("canal dump mysql err: %v", err)
		return errors.Trace(err)
	}

	if err = c.startSyncBinlog(); err != nil {//开始binlog同步
		log.Errorf("canal start sync binlog err: %v", err)
		return errors.Trace(err)
	}

	return nil
}

// dump.go
func (c *Canal) tryDump() error {
	pos := c.master.Position()
	if len(pos.Name) > 0 && pos.Pos > 0 {
		// we will sync with binlog name and position
		log.Infof("skip dump, use last binlog replication pos %s", pos)
		return nil
	}

	if c.dumper == nil {
		log.Info("skip dump, no mysqldump")
		return nil
	}

	h := &dumpParseHandler{c: c}

	start := time.Now()
	log.Info("try dump MySQL and parse")
	if err := c.dumper.DumpAndParse(h); err != nil {
		return errors.Trace(err)
	}

	log.Infof("dump MySQL and parse OK, use %0.2f seconds, start binlog replication at (%s, %d)",
		time.Now().Sub(start).Seconds(), h.name, h.pos)

	c.master.Update(mysql.Position{h.name, uint32(h.pos)})
	return nil
}

//sunc.go
func (c *Canal) startSyncBinlog() error {
	pos := c.master.Position()

	log.Infof("start sync binlog at %v", pos)

	s, err := c.syncer.StartSync(pos)
	if err != nil {
		return errors.Errorf("start sync replication at %v error %v", pos, err)
	}

	for {
		ev, err := s.GetEvent(c.ctx)

		if err != nil {
			return errors.Trace(err)
		}

		curPos := pos.Pos
		//next binlog pos
		pos.Pos = ev.Header.LogPos

		// We only save position with RotateEvent and XIDEvent.
		// For RowsEvent, we can't save the position until meeting XIDEvent
		// which tells the whole transaction is over.
		// TODO: If we meet any DDL query, we must save too.
		switch e := ev.Event.(type) {
		case *replication.RotateEvent:
			pos.Name = string(e.NextLogName)
			pos.Pos = uint32(e.Position)
			log.Infof("rotate binlog to %s", pos)

			if err = c.eventHandler.OnRotate(e); err != nil {
				return errors.Trace(err)
			}
		case *replication.RowsEvent:
			// we only focus row based event
			err = c.handleRowsEvent(ev)
			if err != nil && errors.Cause(err) != schema.ErrTableNotExist {
				// We can ignore table not exist error
				log.Errorf("handle rows event at (%s, %d) error %v", pos.Name, curPos, err)
				return errors.Trace(err)
			}
			continue
		case *replication.XIDEvent:
			// try to save the position later
			if err := c.eventHandler.OnXID(pos); err != nil {
				return errors.Trace(err)
			}
		case *replication.QueryEvent:
			// handle alert table query
			if mb := expAlterTable.FindSubmatch(e.Query); mb != nil {
				if len(mb[1]) == 0 {
					mb[1] = e.Schema
				}
				c.ClearTableCache(mb[1], mb[2])
				log.Infof("table structure changed, clear table cache: %s.%s\n", mb[1], mb[2])
				if err = c.eventHandler.OnDDL(pos, e); err != nil {
					return errors.Trace(err)
				}
			} else {
				// skip others
				continue
			}
		default:
			continue
		}

		c.master.Update(pos)
	}

	return nil
}
```
