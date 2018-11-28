startup
```
git clone  https://github.com/taylorchen709/vue-admin.git
cd vue-admin/
npm install
npm run dev

```
edit theme

```
vim  src/main.js 
import babelpolyfill from 'babel-polyfill'
import Vue from 'vue'
import App from './App'
import ElementUI from 'element-ui'
//import 'element-ui/lib/theme-default/index.css'
import './assets/theme/theme-green/index.css'
//import 'element-ui/lib/theme-chalk/index.css'
//import './assets/theme/theme-darkblue/index.css'
```

