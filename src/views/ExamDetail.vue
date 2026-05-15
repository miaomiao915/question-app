<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// 选项接口
interface Option {
  key: string      // 选项标识(A/B/C/D)
  value: string    // 选项内容
}

// 题目接口
interface Question {
  id: number       // 题目ID
  question: string // 题目内容
  options: Option[] // 选项列表
  answer: string  // 正确答案
}

// 试卷数据接口
interface ExamData {
  id: number       // 试卷ID
  title: string   // 试卷标题
  subject: string // 科目
  total: number   // 总题量
  questions: Question[] // 题目列表
}

const route = useRoute()
const router = useRouter()
const examData = ref<ExamData | null>(null)
const selectedAnswers = ref<Record<number, string>>({})  // 用户选择的答案 {题目ID: 选项key}
const results = ref<Record<number, boolean>>({})           //做题结果 {题目ID: 对错}
const latestQuestionId = ref<number | null>(null)       // 最新操作的题目ID
const examName = ref('')                               // 试卷名称

// 获取localStorage的key
const getStorageKey = (name: string) => `exam_${name}`

// 计算总题数
const totalQuestions = computed(() => examData.value?.questions.length || 0)
// 计算已完成数量
const doneCount = computed(() => Object.keys(selectedAnswers.value).length)
// 计算进度百分比
const progress = computed(() => totalQuestions.value ? Math.round((doneCount.value / totalQuestions.value) * 100) : 0)

// 加载试卷数据
const loadExam = async () => {
  const name = route.params.name as string
  examName.value = name
  try {
    const res = await fetch(`/json/${name}.json`)
    examData.value = await res.json()
    // 从 localStorage 恢复之前做题的数据
    const saved = localStorage.getItem(getStorageKey(name))
    if (saved) {
      const data = JSON.parse(saved)
      selectedAnswers.value = data.selected || {}
      results.value = data.results || {}
      latestQuestionId.value = data.latestId || null
    }
  } catch {
    router.push('/')
  }
}

// 判断是否为多选题(答案长度>1为多选)
const isMultiple = (answer: string) => answer.length > 1

// 保存到localStorage
const saveToStorage = () => {
  const key = getStorageKey(examName.value)
  localStorage.setItem(key, JSON.stringify({
    selected: selectedAnswers.value,
    results: results.value,
    latestId: latestQuestionId.value
  }))
}

// 提交答案
const submitAnswer = (qid: number) => {
  const question = examData.value?.questions.find(q => q.id === qid)
  if (!question) return
  const selected = selectedAnswers.value[qid]
  results.value[qid] = selected === question.answer
  latestQuestionId.value = qid
  saveToStorage()
}

// 处理选项点击
const handleSelect = (qid: number, key: string) => {
  selectedAnswers.value[qid] = key
  saveToStorage()
  // 单选题自动提交
  const question = examData.value?.questions.find(q => q.id === qid)
  if (question && !isMultiple(question.answer)) {
    submitAnswer(qid)
  }
}

// 重新开始(清除缓存)
const restart = () => {
  localStorage.removeItem(getStorageKey(examName.value))
  selectedAnswers.value = {}
  results.value = {}
  latestQuestionId.value = null
}

// 组件挂载时加载数据
onMounted(() => {
  loadExam()
})
</script>

<template>
  <div class="min-h-screen bg-gray-50 p-6 pb-20">
    <div mb-4 flex gap-2>
      <ElButton @click="router.push('/')">返回</ElButton>
      <ElButton type="warning" @click="restart">重新开始</ElButton>
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
        <div v-for="q in examData.questions" :key="q.id" p-4 border-b mb-4>
          <div mb-2>
            <ElTag :type="isMultiple(q.answer) ? 'warning' : 'primary'" size="small">
              {{ isMultiple(q.answer) ? '多选' : '单选' }}
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
              :class="selectedAnswers[q.id] === opt.key ? 'bg-blue-100 border-blue-500' : 'hover:bg-gray-50'"
              @click="handleSelect(q.id, opt.key)"
            >
              {{ opt.key }}. {{ opt.value }}
            </div>
          </div>
          <div mt-3 flex items-center gap-2>
            <ElButton type="primary" size="small" @click="submitAnswer(q.id)">确定</ElButton>
            <ElTag v-if="results[q.id] === true" type="success" size="small">正确</ElTag>
            <ElTag v-if="results[q.id] === false" type="danger" size="small">错误 - 答案: {{ q.answer }}</ElTag>
          </div>
        </div>
      </div>
    </ElCard>
    <!-- 底部进度条 -->
    <div class="fixed bottom-0 left-0 right-0 bg-white border-t h-14 px-4 flex items-center">
      <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden mr-3">
        <div
          class="h-full bg-blue-500 transition-all duration-300"
          :style="{ width: `${progress}%` }"
        />
      </div>
      <span text-sm>{{ doneCount }}/{{ totalQuestions }} ({{ progress }}%)</span>
    </div>
  </div>
</template>