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

const props = withDefaults(defineProps<{
  show?: boolean;
  variant?: 'success' | 'error' | 'warning' | 'info';
}>(), {
  show: true,
  variant: 'info'
})

if (props.show) {
  switch (props.variant) {
    case 'success':
      toast.open({
        message: 'Messaggio di successo',
        type: 'success',
      });
      break;
    case 'error':
      toast.open({
        message: 'Messaggio di errore',
        type: 'error',
      });
      break;
    case 'warning':
      toast.open({
        message: 'Messaggio di avviso',
        type: 'warning',
      });
      break;
    case 'info':
      toast.open({
        message: 'Messaggio informativo',
        type: 'info',
      });
      break;
  }
}
  </script>
