import { createApp } from 'vue'
import { createPinia } from 'pinia'
import Toast, { PluginOptions } from 'vue-toastification';
import 'vue-toastification/dist/index.css';
import App from './App.vue'
import router from './router'
import './style.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
const options: PluginOptions = {
  // You can set your default options here
};

app.use(Toast, options);
app.use(router)
app.mount('#app')
