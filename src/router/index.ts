import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import About from '@/views/About.vue'
import ExamDetail from '@/views/ExamDetail.vue'

const routes = [
  { path: '/', name: 'Home', component: Home },
  { path: '/about', name: 'About', component: About },
  { path: '/exam/:name', name: 'ExamDetail', component: ExamDetail },
]

export const router = createRouter({
  history: createWebHistory(),
  routes,
})