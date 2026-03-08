<template>
  <div>
    <nav style="background:#1e40af;padding:1rem 2rem;display:flex;align-items:center;gap:1.5rem;">
      <span style="color:#fff;font-size:1.25rem;font-weight:700;">Basic CRUD</span>
      <RouterLink to="/" style="color:#bfdbfe;text-decoration:none;">Items</RouterLink>
      <RouterLink to="/items/create" style="color:#bfdbfe;text-decoration:none;">Add Item</RouterLink>
    </nav>
    <main style="max-width:900px;margin:2rem auto;padding:0 1rem;">
      <RouterView />
    </main>
  </div>
</template>
