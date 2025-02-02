<template>
    <div class="flow-root">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th
                    v-for="column in columns"
                    :key="column.key"
                    :class="[
                      'py-3.5 text-sm font-semibold text-gray-900',
                      column.align === 'right' ? 'text-right' : 'text-left',
                      column.align === 'center' ? 'text-center' : '',
                      column.key === 'actions' ? 'relative' : '',
                      column.className
                    ]"
                  >
                    {{ column.label }}
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 bg-white">
                <tr v-for="(item, index) in items" :key="index">
                  <td
                    v-for="column in columns"
                    :key="column.key"
                    :class="[
                      'whitespace-nowrap py-4 text-sm',
                      column.align === 'right' ? 'text-right' : 'text-left',
                      column.align === 'center' ? 'text-center' : '',
                      column.className
                    ]"
                  >
                    <slot :name="column.key" :item="item" :column="column">
                      {{ item[column.key] }}
                    </slot>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  interface Column {
    key: string
    label: string
    align?: 'left' | 'right' | 'center'
    className?: string
  }
  
  defineProps<{
    columns: Column[]
    items: any[]
  }>()
  </script>