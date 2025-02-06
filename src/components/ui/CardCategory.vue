<template>
  <div
    class="flex flex-col items-center p-6 bg-gradient-to-br from-slate-50 to-gray-100 rounded-xl shadow-xl"
  >
    <div
      class="text-center mb-6 bg-gradient-to-r from-blue-600 via-purple-600 to-pink-600 bg-clip-text text-transparent text-3xl font-black tracking-tight"
    >
      {{ category.title }}
    </div>
    <div
      class="border border-gray-200/80 py-3 px-2 flex gap-2 shadow-lg rounded-xl bg-white/80 backdrop-blur-sm hover:shadow-xl transition-all duration-300"
    >
      <div class="group relative px-3 cursor-pointer">
        <div
          class="flex h-10 w-10 items-center justify-center rounded-lg hover:bg-blue-50 hover:text-blue-600 transition-colors duration-300"
        >
          <editIcon></editIcon>
        </div>
        <span
          class="absolute -top-12 left-[50%] -translate-x-[50%] z-20 origin-bottom scale-0 px-3 py-1.5 rounded-lg border border-gray-200 bg-white text-xs font-medium shadow-lg transition-all duration-300 ease-in-out group-hover:scale-100 before:absolute before:bottom-[-5px] before:left-[50%] before:-translate-x-[50%] before:border-[6px] before:border-transparent before:border-t-white"
        >
          Edit
        </span>
      </div>

      <div class="group relative px-3 cursor-pointer">
        <div
          class="flex h-10 w-10 items-center justify-center rounded-lg hover:bg-blue-50 hover:text-blue-600 transition-colors duration-300"
        >
          <svg
            class="group-hover:scale-110 transition-transform duration-300"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M21 11.5C21.0034 12.8199 20.6951 14.1219 20.1 15.3C19.3944 16.7118 18.3098 17.8992 16.9674 18.7293C15.6251 19.5594 14.0782 19.9994 12.5 20C11.1801 20.0035 9.87812 19.6951 8.7 19.1L3 21L4.9 15.3C4.30493 14.1219 3.99656 12.8199 4 11.5C4.00061 9.92179 4.44061 8.37488 5.27072 7.03258C6.10083 5.69028 7.28825 4.6056 8.7 3.90003C9.87812 3.30496 11.1801 2.99659 12.5 3.00003H13C15.0843 3.11502 17.053 3.99479 18.5291 5.47089C20.0052 6.94699 20.885 8.91568 21 11V11.5Z"
              stroke-linejoin="round"
              stroke-linecap="round"
              stroke-width="2"
              stroke="currentColor"
            ></path>
          </svg>
        </div>
        <span
          class="absolute -top-12 left-[50%] -translate-x-[50%] z-20 origin-bottom scale-0 px-3 py-1.5 rounded-lg border border-gray-200 bg-white text-xs font-medium shadow-lg transition-all duration-300 ease-in-out group-hover:scale-100 before:absolute before:bottom-[-5px] before:left-[50%] before:-translate-x-[50%] before:border-[6px] before:border-transparent before:border-t-white"
        >
          Delete
        </span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import editIcon from "@assets/editIcon.svg";

defineProps({
  category: {
    type: Object as () => {
      id: string;
      title: string;
      icon: string;
      color: string;
    },
    required: true,
  },
});

defineEmits(["edit", "delete"]);
</script>
