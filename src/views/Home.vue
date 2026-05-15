<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";

interface ExamItem {
  name: string;
  title: string;
}

const router = useRouter();
const examList = ref<ExamItem[]>([]);

const loadExamList = async () => {
  const names = ["base1", "base2"];
  const exams = await Promise.all(
    names.map((n) => fetch(`/json/${n}.json`).then((r) => r.json())),
  );
  examList.value = exams.map((exam, i) => ({
    name: names[i],
    title: exam.title,
  }));
};

onMounted(loadExamList);
</script>

<template>
  <div class="min-h-screen flex-center bg-gray-50">
    <ElCard class="w-500px" shadow="hover">
      <template #header>
        <div class="font-bold text-lg">试卷列表</div>
      </template>
      <div space-y-3>
        <div
          v-for="item in examList"
          :key="item.name"
          p-3
          border
          rounded
          cursor-pointer
          hover:bg-blue-50
          @click="router.push(`/exam/${item.name}`)"
        >
          {{ item.title }}
        </div>
      </div>
    </ElCard>
  </div>
</template>
