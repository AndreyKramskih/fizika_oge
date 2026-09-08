// lib/data/formulas_data.dart

class Formula {
  final String name;
  final String formula;
  final String description;
  final String topic;

  Formula({
    required this.name,
    required this.formula,
    required this.description,
    required this.topic,
  });
}

class FormulasData {
  static List<Formula> allFormulas = [
    // ========== МЕХАНИКА ==========
    Formula(
      name: 'Скорость',
      formula: 'v = S / t',
      description: 'Скорость = путь / время',
      topic: 'Механика',
    ),
    Formula(
      name: 'Средняя скорость',
      formula: 'vср = Sобщ / tобщ',
      description: 'Средняя скорость = общий путь / общее время',
      topic: 'Механика',
    ),
    Formula(
      name: 'Ускорение',
      formula: 'a = (v - v₀) / t',
      description:
          'Ускорение = (конечная скорость - начальная скорость) / время',
      topic: 'Механика',
    ),
    Formula(
      name: 'Путь при равноускоренном движении',
      formula: 'S = v₀t + at²/2',
      description: 'Путь = начальная скорость × время + ускорение × время² / 2',
      topic: 'Механика',
    ),
    Formula(
      name: 'Скорость при равноускоренном движении',
      formula: 'v = v₀ + at',
      description: 'Скорость = начальная скорость + ускорение × время',
      topic: 'Механика',
    ),
    Formula(
      name: 'Второй закон Ньютона',
      formula: 'F = ma',
      description: 'Сила = масса × ускорение',
      topic: 'Механика',
    ),
    Formula(
      name: 'Сила тяжести',
      formula: 'Fт = mg',
      description: 'Сила тяжести = масса × ускорение свободного падения',
      topic: 'Механика',
    ),
    Formula(
      name: 'Сила трения',
      formula: 'Fтр = μN',
      description: 'Сила трения = коэффициент трения × сила нормальной реакции',
      topic: 'Механика',
    ),
    Formula(
      name: 'Работа',
      formula: 'A = FS',
      description: 'Работа = сила × путь',
      topic: 'Механика',
    ),
    Formula(
      name: 'Кинетическая энергия',
      formula: 'Ek = mv²/2',
      description: 'Кинетическая энергия = масса × скорость² / 2',
      topic: 'Механика',
    ),
    Formula(
      name: 'Потенциальная энергия',
      formula: 'Ep = mgh',
      description: 'Потенциальная энергия = масса × g × высота',
      topic: 'Механика',
    ),
    Formula(
      name: 'Закон сохранения энергии',
      formula: 'Ek₁ + Ep₁ = Ek₂ + Ep₂',
      description: 'Полная механическая энергия сохраняется',
      topic: 'Механика',
    ),
    Formula(
      name: 'Импульс',
      formula: 'p = mv',
      description: 'Импульс = масса × скорость',
      topic: 'Механика',
    ),
    Formula(
      name: 'Закон сохранения импульса',
      formula: 'm₁v₁ + m₂v₂ = m₁v₁\' + m₂v₂\'',
      description: 'Сумма импульсов до взаимодействия = сумме импульсов после',
      topic: 'Механика',
    ),
    Formula(
      name: 'Мощность',
      formula: 'P = A/t = Fv',
      description: 'Мощность = работа / время = сила × скорость',
      topic: 'Механика',
    ),
    Formula(
      name: 'Давление',
      formula: 'p = F/S',
      description: 'Давление = сила / площадь',
      topic: 'Механика',
    ),
    Formula(
      name: 'Давление жидкости',
      formula: 'p = ρgh',
      description: 'Давление жидкости = плотность × g × высота',
      topic: 'Механика',
    ),
    Formula(
      name: 'Сила Архимеда',
      formula: 'Fарх = ρжgVт',
      description: 'Сила Архимеда = плотность жидкости × g × объем тела',
      topic: 'Механика',
    ),
    Formula(
      name: 'Момент силы',
      formula: 'M = Fl',
      description: 'Момент силы = сила × плечо',
      topic: 'Механика',
    ),
    Formula(
      name: 'Условие равновесия рычага',
      formula: 'F₁l₁ = F₂l₂',
      description: 'Произведение силы на плечо равны',
      topic: 'Механика',
    ),
    Formula(
      name: 'КПД механизма',
      formula: 'η = Aпол/Aзатр × 100%',
      description: 'КПД = полезная работа / затраченная работа × 100%',
      topic: 'Механика',
    ),

    // ========== ТЕРМОДИНАМИКА ==========
    Formula(
      name: 'Количество теплоты',
      formula: 'Q = cmΔt',
      description:
          'Количество теплоты = удельная теплоемкость × масса × изменение температуры',
      topic: 'Термодинамика',
    ),
    Formula(
      name: 'Плавление',
      formula: 'Q = λm',
      description: 'Количество теплоты = удельная теплота плавления × масса',
      topic: 'Термодинамика',
    ),
    Formula(
      name: 'Парообразование',
      formula: 'Q = Lm',
      description:
          'Количество теплоты = удельная теплота парообразования × масса',
      topic: 'Термодинамика',
    ),
    Formula(
      name: 'Сгорание топлива',
      formula: 'Q = qm',
      description: 'Количество теплоты = удельная теплота сгорания × масса',
      topic: 'Термодинамика',
    ),
    Formula(
      name: 'КПД теплового двигателя',
      formula: 'η = (Qн - Qх)/Qн × 100%',
      description:
          'КПД = (теплота нагревателя - теплота холодильника) / теплота нагревателя × 100%',
      topic: 'Термодинамика',
    ),
    Formula(
      name: 'Уравнение теплового баланса',
      formula: 'Qотд = Qпол',
      description:
          'Количество теплоты отданное = количеству теплоты полученному',
      topic: 'Термодинамика',
    ),

    // ========== ЭЛЕКТРИЧЕСТВО ==========
    Formula(
      name: 'Закон Ома',
      formula: 'I = U/R',
      description: 'Сила тока = напряжение / сопротивление',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Сопротивление проводника',
      formula: 'R = ρl/S',
      description:
          'Сопротивление = удельное сопротивление × длина / площадь сечения',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Последовательное соединение',
      formula: 'R = R₁ + R₂ + ...',
      description: 'Общее сопротивление = сумме сопротивлений',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Параллельное соединение',
      formula: '1/R = 1/R₁ + 1/R₂ + ...',
      description: 'Обратное сопротивление = сумме обратных сопротивлений',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Мощность тока',
      formula: 'P = UI = I²R = U²/R',
      description: 'Мощность = напряжение × сила тока',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Работа тока',
      formula: 'A = UIt',
      description: 'Работа = напряжение × сила тока × время',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Закон Джоуля-Ленца',
      formula: 'Q = I²Rt',
      description: 'Количество теплоты = сила тока² × сопротивление × время',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Закон Ома для полной цепи',
      formula: 'I = ε/(R + r)',
      description:
          'Сила тока = ЭДС / (внешнее сопротивление + внутреннее сопротивление)',
      topic: 'Электричество',
    ),
    Formula(
      name: 'Сила тока',
      formula: 'I = q/t',
      description: 'Сила тока = заряд / время',
      topic: 'Электричество',
    ),

    // ========== ОПТИКА ==========
    Formula(
      name: 'Оптическая сила линзы',
      formula: 'D = 1/F',
      description: 'Оптическая сила = 1 / фокусное расстояние',
      topic: 'Оптика',
    ),
    Formula(
      name: 'Формула тонкой линзы',
      formula: '1/F = 1/d + 1/f',
      description:
          '1/фокусное расстояние = 1/расстояние до предмета + 1/расстояние до изображения',
      topic: 'Оптика',
    ),
    Formula(
      name: 'Закон преломления',
      formula: 'n = sin α / sin β = c/v',
      description:
          'Показатель преломления = синус угла падения / синус угла преломления = скорость света в вакууме / скорость света в среде',
      topic: 'Оптика',
    ),
    Formula(
      name: 'Закон отражения',
      formula: 'α = β',
      description: 'Угол падения = угол отражения',
      topic: 'Оптика',
    ),
    Formula(
      name: 'Увеличение линзы',
      formula: 'Γ = f/d = H/h',
      description:
          'Увеличение = расстояние до изображения / расстояние до предмета = высота изображения / высота предмета',
      topic: 'Оптика',
    ),

    // ========== АТОМНАЯ ФИЗИКА ==========
    Formula(
      name: 'Энергия связи',
      formula: 'Eсв = Δm·c²',
      description: 'Энергия связи = дефект масс × скорость света²',
      topic: 'Атомная физика',
    ),
    Formula(
      name: 'Дефект масс',
      formula: 'Δm = (Zmp + Nmn) - Mя',
      description:
          'Дефект масс = (число протонов × масса протона + число нейтронов × масса нейтрона) - масса ядра',
      topic: 'Атомная физика',
    ),
    Formula(
      name: 'Закон радиоактивного распада',
      formula: 'N = N₀·2^(-t/T)',
      description:
          'Число атомов = начальное число × 2^(-время / период полураспада)',
      topic: 'Атомная физика',
    ),
    Formula(
      name: 'Период полураспада',
      formula: 'T₁/₂ = 0.693/λ',
      description: 'Период полураспада = 0.693 / постоянная распада',
      topic: 'Атомная физика',
    ),

    // ========== КОЛЕБАНИЯ И ВОЛНЫ ==========
    Formula(
      name: 'Период колебаний',
      formula: 'T = 1/ν = t/N',
      description: 'Период = 1 / частота = время / число колебаний',
      topic: 'Колебания',
    ),
    Formula(
      name: 'Частота колебаний',
      formula: 'ν = 1/T = N/t',
      description: 'Частота = 1 / период = число колебаний / время',
      topic: 'Колебания',
    ),
    Formula(
      name: 'Длина волны',
      formula: 'λ = vT = v/ν',
      description: 'Длина волны = скорость × период = скорость / частота',
      topic: 'Колебания',
    ),
    Formula(
      name: 'Скорость волны',
      formula: 'v = λν = λ/T',
      description:
          'Скорость волны = длина волны × частота = длина волны / период',
      topic: 'Колебания',
    ),
    Formula(
      name: 'Период пружинного маятника',
      formula: 'T = 2π√(m/k)',
      description: 'Период = 2π × √(масса / жесткость)',
      topic: 'Колебания',
    ),
    Formula(
      name: 'Период математического маятника',
      formula: 'T = 2π√(l/g)',
      description: 'Период = 2π × √(длина / ускорение свободного падения)',
      topic: 'Колебания',
    ),
  ];

  static List<String> getTopics() {
    return allFormulas.map((f) => f.topic).toSet().toList();
  }

  static List<Formula> getFormulasByTopic(String topic) {
    return allFormulas.where((f) => f.topic == topic).toList();
  }
}
