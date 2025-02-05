<template>
    <div
      v-if="modelValue"
      class="relative z-50"
      aria-labelledby="modal-title"
      role="dialog"
      aria-modal="true"
    >
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
  
      <div class="fixed inset-0 z-50 overflow-y-auto">
        <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <div
            class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full"
            :class="[size === 'sm' ? 'sm:max-w-sm' : 'sm:max-w-lg']"
          >
            <div class="absolute right-0 top-0 pr-4 pt-4">
              <button
                type="button"
                @click="$emit('update:modelValue', false)"
                class="rounded-md bg-white text-gray-400 hover:text-gray-500"
              >
                <XMarkIcon class="h-6 w-6" />
              </button>
            </div>
  
            <div class="sm:flex sm:items-start">
              <div v-if="icon" class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full sm:mx-0 sm:h-10 sm:w-10" :class="iconBackgroundClass">
                <component :is="icon" class="h-6 w-6" :class="iconClass" aria-hidden="true" />
              </div>
              <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left w-full">
                <h3 v-if="title" class="text-base font-semibold leading-6 text-gray-900">
                  {{ title }}
                </h3>
                <div class="mt-2">
                  <slot></slot>
                </div>
              </div>
            </div>
  
            <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
              <slot name="footer"></slot>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  import { XMarkIcon } from '@heroicons/vue/24/outline'
  
  withDefaults(defineProps<{
    modelValue: boolean
    title?: string
    size?: 'sm' | 'lg'
    icon?: any
    iconClass?: string
    iconBackgroundClass?: string
  }>(), {
    size: 'lg'
  })
  
  defineEmits(['update:modelValue'])
  </script>
