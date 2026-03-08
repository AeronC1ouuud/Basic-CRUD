import { createRouter, createWebHistory } from 'vue-router'
import ItemList from '../views/ItemList.vue'
import ItemForm from '../views/ItemForm.vue'

const routes = [
  { path: '/',                name: 'items.index',  component: ItemList },
  { path: '/items/create',    name: 'items.create', component: ItemForm },
  { path: '/items/:id/edit',  name: 'items.edit',   component: ItemForm },
]

export default createRouter({
  history: createWebHistory(),
  routes,
})
