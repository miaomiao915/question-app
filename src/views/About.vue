<script setup lang="ts">
import { useRouter } from 'vue-router'
const router = useRouter()
</script>

<template>
  <div class="min-h-screen flex-center bg-gray-50">
    <ElCard class="w-400px" shadow="hover">
      <template #header>
        <div class="font-bold text-lg">关于页面</div>
      </template>
      <div space-y-4>
        <p text-gray-600>这是关于页面</p>
        <ElButton @click="router.push('/')">返回首页</ElButton>
      </div>
    </ElCard>
  </div>
</template>