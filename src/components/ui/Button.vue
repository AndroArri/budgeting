<template>
  <span
    :class="[
      'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
      variant === 'primary' && 'bg-green-100 text-green-800',
      variant === 'abort' && 'bg-red-100 text-red-800',
      variant === 'warning' && 'bg-yellow-100 text-yellow-800',
      variant === 'info' && 'bg-blue-100 text-blue-800',
      variant === 'secondary' && 'bg-gray-100 text-gray-800',
    ]"
  >
    <slot></slot>
  </span>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: "primary" | "abort" | "warning" | "info" | "secondary";
  }>(),
  {
    variant: "secondary",
  }
);
</script>
