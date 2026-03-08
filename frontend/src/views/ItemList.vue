<template>
  <div>
    <h1>Items</h1>
    <p v-if="loading">Loading…</p>
    <p v-else-if="error" style="color:red;">{{ error }}</p>
    <template v-else>
      <p v-if="items.length === 0">No items yet. <RouterLink to="/items/create">Add one!</RouterLink></p>
      <table v-else style="width:100%;border-collapse:collapse;background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,.08);">
        <thead style="background:#1e40af;color:#fff;">
          <tr>
            <th style="padding:.75rem 1rem;text-align:left;">Name</th>
            <th style="padding:.75rem 1rem;text-align:left;">Description</th>
            <th style="padding:.75rem 1rem;text-align:right;">Qty</th>
            <th style="padding:.75rem 1rem;text-align:right;">Price</th>
            <th style="padding:.75rem 1rem;text-align:center;">Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.id" style="border-bottom:1px solid #e5e7eb;">
            <td style="padding:.75rem 1rem;">{{ item.name }}</td>
            <td style="padding:.75rem 1rem;color:#6b7280;">{{ item.description || '—' }}</td>
            <td style="padding:.75rem 1rem;text-align:right;">{{ item.quantity }}</td>
            <td style="padding:.75rem 1rem;text-align:right;">${{ Number(item.price).toFixed(2) }}</td>
            <td style="padding:.75rem 1rem;text-align:center;display:flex;gap:.5rem;justify-content:center;">
              <RouterLink :to="`/items/${item.id}/edit`" style="padding:.3rem .75rem;background:#1e40af;color:#fff;border-radius:4px;text-decoration:none;font-size:.875rem;">Edit</RouterLink>
              <button @click="remove(item.id)" style="padding:.3rem .75rem;background:#dc2626;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:.875rem;">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const items   = ref([])
const loading = ref(true)
const error   = ref(null)

async function fetchItems() {
  try {
    loading.value = true
    error.value   = null
    const res = await axios.get('/items')
    items.value = res.data
  } catch (e) {
    error.value = 'Failed to load items.'
  } finally {
    loading.value = false
  }
}

async function remove(id) {
  if (!confirm('Delete this item?')) return
  await axios.delete(`/items/${id}`)
  items.value = items.value.filter(i => i.id !== id)
}

onMounted(fetchItems)
</script>
