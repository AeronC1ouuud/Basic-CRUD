<template>
  <div>
    <h1>{{ isEdit ? 'Edit Item' : 'New Item' }}</h1>
    <p v-if="fetchError" style="color:red;">{{ fetchError }}</p>
    <form v-else @submit.prevent="submit" style="background:#fff;padding:1.5rem;border-radius:8px;box-shadow:0 1px 4px rgba(0,0,0,.08);max-width:500px;">
      <div style="margin-bottom:1rem;">
        <label style="display:block;margin-bottom:.25rem;font-weight:600;">Name *</label>
        <input v-model="form.name" type="text" required style="width:100%;padding:.5rem .75rem;border:1px solid #d1d5db;border-radius:4px;" />
        <span v-if="errors.name" style="color:red;font-size:.875rem;">{{ errors.name[0] }}</span>
      </div>
      <div style="margin-bottom:1rem;">
        <label style="display:block;margin-bottom:.25rem;font-weight:600;">Description</label>
        <textarea v-model="form.description" rows="3" style="width:100%;padding:.5rem .75rem;border:1px solid #d1d5db;border-radius:4px;"></textarea>
      </div>
      <div style="margin-bottom:1rem;display:flex;gap:1rem;">
        <div style="flex:1;">
          <label style="display:block;margin-bottom:.25rem;font-weight:600;">Quantity *</label>
          <input v-model.number="form.quantity" type="number" min="0" required style="width:100%;padding:.5rem .75rem;border:1px solid #d1d5db;border-radius:4px;" />
          <span v-if="errors.quantity" style="color:red;font-size:.875rem;">{{ errors.quantity[0] }}</span>
        </div>
        <div style="flex:1;">
          <label style="display:block;margin-bottom:.25rem;font-weight:600;">Price *</label>
          <input v-model.number="form.price" type="number" min="0" step="0.01" required style="width:100%;padding:.5rem .75rem;border:1px solid #d1d5db;border-radius:4px;" />
          <span v-if="errors.price" style="color:red;font-size:.875rem;">{{ errors.price[0] }}</span>
        </div>
      </div>
      <div style="display:flex;gap:1rem;align-items:center;">
        <button type="submit" :disabled="saving" style="padding:.5rem 1.5rem;background:#1e40af;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:1rem;">
          {{ saving ? 'Saving…' : 'Save' }}
        </button>
        <RouterLink to="/" style="color:#6b7280;text-decoration:none;">Cancel</RouterLink>
      </div>
      <p v-if="submitError" style="margin-top:.75rem;color:red;">{{ submitError }}</p>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route  = useRoute()
const router = useRouter()

const isEdit = computed(() => !!route.params.id)

const form = reactive({ name: '', description: '', quantity: 0, price: 0 })
const errors      = ref({})
const saving      = ref(false)
const fetchError  = ref(null)
const submitError = ref(null)

onMounted(async () => {
  if (!isEdit.value) return
  try {
    const res = await axios.get(`/items/${route.params.id}`)
    Object.assign(form, res.data)
  } catch {
    fetchError.value = 'Item not found.'
  }
})

async function submit() {
  errors.value      = {}
  submitError.value = null
  saving.value      = true
  try {
    if (isEdit.value) {
      await axios.put(`/items/${route.params.id}`, form)
    } else {
      await axios.post('/items', form)
    }
    router.push('/')
  } catch (e) {
    if (e.response?.status === 422) {
      errors.value = e.response.data.errors || {}
    } else {
      submitError.value = 'An error occurred. Please try again.'
    }
  } finally {
    saving.value = false
  }
}
</script>
