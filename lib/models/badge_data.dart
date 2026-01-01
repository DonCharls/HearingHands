final List<Map<String, dynamic>> allBadges = [
  // ==========================================
  // 1. ENGAGEMENT & STREAKS (The easiest hooks)
  // ==========================================
  {
    "title": "Trailblazer",
    "desc": "Log in for the first time.",
    "image": "assets/images/awards/trailblazer.png",
    "check": (Map<String, dynamic> data) => true, // Always true if logged in
  },
  {
    "title": "Two Day Champ",
    "desc": "Maintain a 2-day learning streak.",
    "image": "assets/images/awards/twodaychamp.png",
    "check": (Map<String, dynamic> data) => (data['streak'] ?? 0) >= 2,
  },
  {
    "title": "Five Day Champ",
    "desc": "Maintain a 5-day learning streak.",
    "image": "assets/images/awards/fivedaychamp.png",
    "check": (Map<String, dynamic> data) => (data['streak'] ?? 0) >= 5,
  },
  {
    "title": "Lucky Seven",
    "desc": "Reach a 7-day streak!",
    "image": "assets/images/awards/luckyseven.png",
    "check": (Map<String, dynamic> data) => (data['streak'] ?? 0) >= 7,
  },
  {
    "title": "Two Week Streaker",
    "desc": "Consistency is key! 14 days in a row.",
    "image": "assets/images/awards/twoweekstreaker.png",
    "check": (Map<String, dynamic> data) => (data['streak'] ?? 0) >= 14,
  },

  // ==========================================
  // 2. LESSON PROGRESS (Alphabet)
  // ==========================================
  {
    "title": "Quick Learner",
    "desc": "Complete your very first lesson (ABC).",
    "image": "assets/images/awards/quicklearner.png",
    "check": (Map<String, dynamic> data) => data['lesson_abc_done'] == true,
  },
  {
    "title": "Triple Threat",
    "desc": "Finish 3 lessons (ABC, DEF, GHI).",
    "image": "assets/images/awards/triplethreat.png",
    "check": (Map<String, dynamic> data) =>
        data['lesson_abc_done'] == true &&
        data['lesson_def_done'] == true &&
        data['lesson_ghi_done'] == true,
  },
  {
    "title": "Alphabet Ace",
    "desc": "Complete the entire Alphabet (A-Z).",
    "image": "assets/images/awards/alphabetace.png",
    "check": (Map<String, dynamic> data) => data['lesson_yz_done'] == true,
  },

  // ==========================================
  // 3. ADVANCED TOPICS (Coming Soon / Locked)
  // ==========================================
  {
    "title": "Number Ninja",
    "desc": "Complete the Numbers 1-10 lesson.",
    "image": "assets/images/awards/numberninja.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Connect when numbers lesson exists
  },
  {
    "title": "Greetings Guru",
    "desc": "Master basic greetings and phrases.",
    "image": "assets/images/awards/greetingsguru.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Connect when greetings lesson exists
  },
  {
    "title": "Feelings Friend",
    "desc": "Learn how to express emotions in signs.",
    "image": "assets/images/awards/feelingsfriend.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Connect when feelings lesson exists
  },

  // ==========================================
  // 4. MASTERY & EXPLORATION
  // ==========================================
  {
    "title": "Lesson Master",
    "desc": "Learn over 50 unique signs.",
    "image": "assets/images/awards/lessonmaster.png",
    "check": (Map<String, dynamic> data) => (data['signsLearned'] ?? 0) >= 50,
  },
  {
    "title": "Dictionary Explorer",
    "desc": "Visit the Dictionary tab.",
    "image": "assets/images/awards/dictionaryexplorer.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Add flag when user visits dictionary
  },
  {
    "title": "Quiz Rookie",
    "desc": "Take your first Sign Language Quiz.",
    "image": "assets/images/awards/quizrookie.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Connect to Quiz logic
  },
  {
    "title": "Quiz Whiz",
    "desc": "Get a perfect score (10/10) on a quiz.",
    "image": "assets/images/awards/quizwhiz.png",
    "check": (Map<String, dynamic> data) =>
        false, // TODO: Connect to Quiz logic
  },
];
