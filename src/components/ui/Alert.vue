<template>
    <div v-if="show" :class="[
      'rounded-md p-4',
      variant === 'success' && 'mt-4 rounded-md bg-green-50 p-4',
      variant === 'error' && 'bg-red-50',
      variant === 'warning' && 'bg-yellow-50',
      variant === 'info' && 'bg-blue-50'
    ]">
      <div :class="[
        'text-sm',
        variant === 'success' && 'text-green-700',
        variant === 'error' && 'text-red-700',
        variant === 'warning' && 'text-yellow-700',
        variant === 'info' && 'text-blue-700'
      ]">
        <slot></slot>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
import { useToast } from 'vue-toast-notification';

const toast = useToast();

withDefaults(defineProps<{
  show?: boolean
  variant?: 'success' | 'error' | 'warning' | 'info',
}>, {
  show: true,
  variant: 'info'
});

if (show) {
  switch (variant) {
    case 'success':
      toast.open({
        message: 'Success message',
        type: 'success',
      });
      break;
    case 'error':
      toast.open({
        message: 'Error message',
        type: 'error',
      });
      break;
    case 'warning':
      toast.open({
        message: 'Warning message',
        type: 'warning',
      });
      break;
    case 'info':
      toast.open({
        message: 'Info message',
        type: 'info',
      });
      break;
  }
}
  </script>
