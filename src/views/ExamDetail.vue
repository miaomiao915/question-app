<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";

// 选项接口
interface Option {
  key: string; // 选项标识(A/B/C/D)
  value: string; // 选项内容
}

// 题目接口
interface Question {
  id: number; // 题目ID
  question: string; // 题目内容
  options: Option[]; // 选项列表
  answer: string; // 正确答案
}

// 试卷数据接口
interface ExamData {
  id: number; // 试卷ID
  title: string; // 试卷标题
  subject: string; // 科目
  total: number; // 总题量
  questions: Question[]; // 题目列表
}

const route = useRoute();
const router = useRouter();
const examData = ref<ExamData | null>(null);
const selectedAnswers = ref<Record<number, string[]>>({}); // 用户选择的答案 {题目ID: 选项key数组}
const results = ref<Record<number, boolean>>({}); //做题结果 {题目ID: 对错}
const latestQuestionId = ref<number | null>(null); // 最新操作的题目ID
const examName = ref(""); // 试卷名称

// 悬浮球拖动相关
const ballRef = ref<HTMLElement | null>(null);
const isDragging = ref(false);
const ballPosition = ref({
  x: window.innerWidth - 60,
  y: window.innerHeight - 120,
});
const dragOffset = ref({ x: 0, y: 0 });

// 获取localStorage的key
const getStorageKey = (name: string) => `exam_${name}`;

// 计算总题数
const totalQuestions = computed(() => examData.value?.questions.length || 0);
// 计算已完成数量
const doneCount = computed(
  () =>
    Object.values(selectedAnswers.value).filter((arr) => arr && arr.length > 0)
      .length,
);
// 计算进度百分比
const progress = computed(() =>
  totalQuestions.value
    ? Math.round((doneCount.value / totalQuestions.value) * 100)
    : 0,
);

// 找到第一道未做的题目
const firstUndoneQuestion = computed(() => {
  if (!examData.value) return null;
  return examData.value.questions.find(
    (q) =>
      !selectedAnswers.value[q.id] || selectedAnswers.value[q.id].length === 0,
  );
});

// 点击底部进度条跳转到第一道未做的题
const scrollToFirstUndone = () => {
  if (!firstUndoneQuestion.value) return;
  const element = document.getElementById(
    `question-${firstUndoneQuestion.value.id}`,
  );
  if (element) {
    element.scrollIntoView({ behavior: "smooth", block: "start" });
  }
};

// 加载试卷数据
const loadExam = async () => {
  const name = route.params.name as string;
  examName.value = name;
  try {
    const res = await fetch(`/json/${name}.json`);
    examData.value = await res.json();
    // 从 localStorage 恢复之前做题的数据
    const saved = localStorage.getItem(getStorageKey(name));
    if (saved) {
      const data = JSON.parse(saved);
      // 兼容旧数据格式（string）和新数据格式（string[]）
      const oldSelected = data.selected || {};
      selectedAnswers.value = Object.fromEntries(
        Object.entries(oldSelected).map(([k, v]) => [
          k,
          Array.isArray(v) ? v : [v],
        ]),
      );
      results.value = data.results || {};
      latestQuestionId.value = data.latestId || null;
    }
  } catch {
    router.push("/");
  }
};

// 判断是否为多选题(答案长度>1为多选)
const isMultiple = (answer: string) => answer.length > 1;

// 保存到localStorage
const saveToStorage = () => {
  const key = getStorageKey(examName.value);
  localStorage.setItem(
    key,
    JSON.stringify({
      selected: selectedAnswers.value,
      results: results.value,
      latestId: latestQuestionId.value,
    }),
  );
};

// 提交答案
const submitAnswer = (qid: number) => {
  const question = examData.value?.questions.find((q) => q.id === qid);
  if (!question) return;
  const selected = selectedAnswers.value[qid] || [];
  // 多选：比较数组内容是否相同（忽略顺序）
  // 单选：比较字符串
  if (isMultiple(question.answer)) {
    const correctAnswers = question.answer.split("");
    const selectedSorted = [...selected].sort();
    const correctSorted = [...correctAnswers].sort();
    results.value[qid] =
      JSON.stringify(selectedSorted) === JSON.stringify(correctSorted);
  } else {
    results.value[qid] = selected[0] === question.answer;
  }
  latestQuestionId.value = qid;
  saveToStorage();
};

// 回到顶部
const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: "smooth" });
};

// 拖动开始
const onDragStart = (e: PointerEvent) => {
  isDragging.value = true;
  const ball = ballRef.value;
  if (!ball) return;
  dragOffset.value = {
    x: e.clientX - ball.offsetLeft,
    y: e.clientY - ball.offsetTop,
  };
  document.addEventListener("pointermove", onDragMove);
  document.addEventListener("pointerup", onDragEnd);
};

// 拖动中
const onDragMove = (e: PointerEvent) => {
  if (!isDragging.value) return;
  ballPosition.value = {
    x: e.clientX - dragOffset.value.x,
    y: e.clientY - dragOffset.value.y,
  };
};

// 拖动结束
const onDragEnd = () => {
  isDragging.value = false;
  document.removeEventListener("pointermove", onDragMove);
  document.removeEventListener("pointerup", onDragEnd);
};

// 处理选项点击
const handleSelect = (qid: number, key: string) => {
  const question = examData.value?.questions.find((q) => q.id === qid);
  if (!question) return;

  if (isMultiple(question.answer)) {
    // 多选：支持toggle
    const current = selectedAnswers.value[qid] || [];
    const index = current.indexOf(key);
    if (index > -1) {
      current.splice(index, 1);
    } else {
      current.push(key);
    }
    selectedAnswers.value[qid] = [...current];
  } else {
    // 单选：直接赋值
    selectedAnswers.value[qid] = [key];
  }
  saveToStorage();
  // 单选题自动提交
  if (!isMultiple(question.answer)) {
    submitAnswer(qid);
  }
};

// 重新开始(清除缓存)
const restart = () => {
  localStorage.removeItem(getStorageKey(examName.value));
  selectedAnswers.value = {};
  results.value = {};
  latestQuestionId.value = null;
};

// 组件挂载时加载数据
onMounted(() => {
  loadExam();
});
</script>

<template>
  <div class="min-h-screen pt-80px pb-20">
    <!-- 固定顶部导航栏 -->
    <div
      class="fixed top-0 left-0 right-0 h-50px bg-white border-b px-4 pt-30px flex items-center justify-between z-10"
    >
      <ElButton size="small" @click="router.push('/')">返回</ElButton>
      <ElButton size="small" type="warning" @click="restart">重新开始</ElButton>
    </div>
    <ElCard v-if="examData" shadow="hover">
      <template #header>
        <div class="font-bold text-lg">{{ examData.title }}</div>
      </template>
      <div space-y-3>
        <p>科目: {{ examData.subject }}</p>
        <p>总题量: {{ examData.total }}</p>
      </div>
      <ElDivider />
      <div>
        <div font-bold mb-2>题目列表:</div>
        <div
          v-for="q in examData.questions"
          :key="q.id"
          :id="`question-${q.id}`"
          p-4
          border-b
          mb-4
        >
          <div mb-2>
            <ElTag
              :type="isMultiple(q.answer) ? 'warning' : 'primary'"
              size="small"
            >
              {{ isMultiple(q.answer) ? "多选" : "单选" }}
            </ElTag>
            <span font-medium ml-2>{{ q.id }}. {{ q.question }}</span>
          </div>
          <div space-y-2 ml-4>
            <div
              v-for="opt in q.options"
              :key="opt.key"
              p-2
              border
              rounded
              cursor-pointer
              :class="
                (selectedAnswers[q.id] || []).includes(opt.key)
                  ? 'bg-blue-100 border-blue-500'
                  : 'hover:bg-gray-50'
              "
              @click="handleSelect(q.id, opt.key)"
            >
              {{ opt.key }}. {{ opt.value }}
            </div>
          </div>
          <div mt-3 flex justify-between items-center gap-2>
            <div min-w-100px>
              <ElTag v-if="results[q.id] === true" type="success" size="small"
                >正确</ElTag
              >
              <ElTag v-if="results[q.id] === false" type="danger" size="small"
                >错误 - 答案: {{ q.answer }}</ElTag
              >
            </div>
            <ElButton
              v-if="isMultiple(q.answer)"
              type="primary"
              size="small"
              @click="submitAnswer(q.id)"
              >确定</ElButton
            >
          </div>
        </div>
      </div>
    </ElCard>
    <!-- 底部进度条 -->
    <div
      class="fixed bottom-0 left-0 right-0 bg-white border-t h-14 px-4 flex items-center cursor-pointer"
      @click="scrollToFirstUndone"
    >
      <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden mr-3">
        <div
          class="h-full bg-blue-500 transition-all duration-300"
          :style="{ width: `${progress}%` }"
        />
      </div>
      <span text-sm
        >{{ doneCount }}/{{ totalQuestions }} ({{ progress }}%)</span
      >
    </div>
    <!-- 悬浮回到顶部按钮 -->
    <div
      ref="ballRef"
      class="fixed w-10 h-10 rounded-full bg-blue-500 text-white flex items-center justify-center cursor-pointer shadow-lg hover:bg-blue-600 transition-colors select-none z-100"
      :style="{ left: ballPosition.x + 'px', top: ballPosition.y + 'px' }"
      @click="scrollToTop"
      @pointerdown="onDragStart"
    >
      ↑
    </div>
  </div>
</template>
