<template>
    <span
      :class="[
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
        variant === 'success' && 'bg-green-100 text-green-800',
        variant === 'error' && 'bg-red-100 text-red-800',
        variant === 'warning' && 'bg-yellow-100 text-yellow-800',
        variant === 'info' && 'bg-blue-100 text-blue-800',
        variant === 'gray' && 'bg-gray-100 text-gray-800'
      ]"
    >
      <slot></slot>
    </span>
  </template>
  
  <script setup lang="ts">
  withDefaults(defineProps<{
    variant?: 'success' | 'error' | 'warning' | 'info' | 'gray'
  }>(), {
    variant: 'gray'
  })
  </script>