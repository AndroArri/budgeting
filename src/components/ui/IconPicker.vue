<script setup lang="ts">
import { ref, computed } from 'vue'
import * as OutlineIcons from '@heroicons/vue/24/outline'
import Input from './Input.vue'

// Most commonly used icons first
const commonIcons = [
  'HomeIcon',
  'UserIcon',
  'CreditCardIcon',
  'ShoppingCartIcon',
  'CalendarIcon',
  'BanknotesIcon',
  'BuildingOfficeIcon',
  'CarIcon',
  'HeartIcon',
  'PhoneIcon',
  'EnvelopeIcon',
  'GlobeAltIcon'
]

const icons = Object.entries(OutlineIcons).map(([name, component]) => ({
  name: name.replace(/Icon$/, ''),
  component
}))

const searchQuery = ref('')

const filteredIcons = computed(() => {
  const query = searchQuery.value.toLowerCase()
  
  // If no search query, show common icons first
  if (!query) {
    const commonIconComponents = commonIcons.map(iconName => 
      icons.find(icon => icon.name + 'Icon' === iconName)
    ).filter((icon): icon is { name: string; component: any } => icon !== undefined)
    
    return commonIconComponents
  }

  // If searching, filter all icons
  return icons.filter(icon => 
    icon.name.toLowerCase().includes(query)
  ).slice(0, 12) // Limit to 12 icons (2 rows of 6)
})

defineProps<{
  modelValue: string
}>()

defineEmits(['update:modelValue'])
</script>

<template>
  <div class="space-y-2">
    <Input
      type="text"
      v-model="searchQuery"
      placeholder="Search icons..."
    />
    <div class="grid grid-cols-6 gap-2 p-2">
      <button
        v-for="icon in filteredIcons"
        :key="icon.name"
        type="button"
        @click="$emit('update:modelValue', icon.name)"
        :class="[
          'p-2 rounded-md hover:bg-gray-100 flex items-center justify-center',
          modelValue === icon.name && 'bg-indigo-100 ring-2 ring-indigo-500'
        ]"
      >
        <component :is="icon.component" class="h-5 w-5" />
      </button>
    </div>
  </div>
</template>