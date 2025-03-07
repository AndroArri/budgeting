<template>
  <div>
    <label
      v-if="label"
      :for="id"
      class="block text-sm font-medium text-gray-700"
    >
      {{ label }}
    </label>
    <div class="relative mt-1">
      <div
        v-if="prefix"
        class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
      >
        <span class="text-gray-500 sm:text-sm">{{ prefix }}</span>
      </div>
      <input
        :id="id"
        :type="type"
        :value="modelValue"
        @input="updateValue"
        :required="required"
        :disabled="disabled"
        :placeholder="placeholder"
        :min="min"
        :max="max"
        :step="step"
        :class="[
          'w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition duration-300',
          disabled ? 'bg-gray-200 cursor-not-allowed' : '',
          prefix && 'pl-10',
          disabled && 'bg-gray-100 cursor-not-allowed',
          error &&
            'border-red-300 text-red-900 placeholder-red-300 focus:border-red-500 focus:ring-red-500',
        ]"
        v-bind="$attrs"
      />
    </div>
    <p v-if="error" class="mt-2 text-sm text-red-600">{{ error }}</p>
    <p v-if="hint" class="mt-2 text-sm text-gray-500">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue: string | number | null;
    id?: string;
    label?: string;
    type?: string;
    required?: boolean;
    disabled?: boolean;
    placeholder?: string;
    prefix?: string;
    error?: string;
    hint?: string;
    min?: number | string;
    max?: number | string;
    step?: number | string;
  }>(),
  {
    type: "text",
    required: false,
    disabled: false,
  }
);

const emit = defineEmits(["update:modelValue"]);

function updateValue(event: Event) {
  const target = event.target as HTMLInputElement;
  emit("update:modelValue", target.value);
}
</script>
