#go struct interface

### struct

### interface  

如果一个struct实现了interface的所有方法，就说改struct实现了该interface


```
package main

import (
	"fmt"
	"math"
)

/*
see: https://gobyexample.com/interfaces
 */
//定义一个interface
type geometry interface {
	area() float64
	perim() float64
}

//定义两个struct：rect，circle
type rect struct {
	width, height float64
}
type circle struct {
	radius float64
}
//rect实现interface geometry的方法
func (r rect) area() float64 {
	return r.width * r.height
}
func (r rect) perim() float64 {
	return 2*r.width + 2*r.height
}
//circle实现interface geometry的方法
func (c circle) area() float64 {
	return math.Pi * c.radius * c.radius
}
func (c circle) perim() float64 {
	return 2 * math.Pi * c.radius
}

func measure(g geometry) {
	fmt.Println(g)
	fmt.Println("area: ",g.area())
	fmt.Println("perim",g.perim())
}
func main() {
	r := rect{width: 3, height: 4}
	c := circle{radius: 5}

		measure(r)
		measure(c)
	}
```
