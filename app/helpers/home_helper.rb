# frozen_string_literal: true

module HomeHelper
  CODICA_URL = 'https://codica.la'

  # Метки UTM для переходов с главной на codica.la (ТЗ главной, п. 8)
  CODICA_UTM = { utm_source: 'basicos', utm_medium: 'site', utm_campaign: 'home_carreras' }.freeze

  # Карьеры Códica из блока «¿Y después de los cursos gratuitos?»; тексты — в локали web.home.careers.items.<key>
  CODICA_CAREERS = [
    { key: 'frontend', badge: 'FE', path: '/carreras/frontend' },
    { key: 'fullstack', badge: 'FS', path: '/carreras/fullstack' },
    { key: 'python', badge: 'Py', path: '/carreras/python' }
  ].freeze

  # Содержимое иконок (статические строки, не пользовательский ввод)
  STEP_ICON_SHAPES = {
    'theory' => '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
    'practice' => '<polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/>',
    'check' => '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>'
  }.freeze

  def codica_url(path)
    "#{CODICA_URL}#{path}?#{CODICA_UTM.map { |key, value| "#{key}=#{value}" }.join('&')}"
  end

  # Короткая метка в плашке курса: HTML, CSS, Py, JS, Java, PHP (текст, не логотипы)
  def course_badge(slug)
    t("web.home.courses.badges.#{slug}", default: slug.to_s.first(3).capitalize)
  end

  # Код в карточке-примере hero: статический HTML, подсветка CSS-классами (k — ключевое слово, n — число, c — комментарий)
  def home_example_code(comment)
    code_span = ->(klass, text) { content_tag(:span, text, class: klass) }

    lines = [
      [code_span.call('c', comment)],
      [code_span.call('k', 'print'), '(', code_span.call('n', '5'), ' > ', code_span.call('n', '4'), ')'],
      [code_span.call('k', 'print'), '(', code_span.call('n', '3'), ' < ', code_span.call('n', '1'), ')']
    ]
    safe_join(lines.map { |parts| safe_join(parts) }, "\n")
  end

  # Иконки шагов «Así aprendes» — инлайн SVG (штрих 1,8, currentColor), декоративные
  def home_step_icon(step)
    shapes = STEP_ICON_SHAPES.fetch(step.to_s)
    content_tag(:svg, shapes.html_safe, viewBox: '0 0 24 24', focusable: 'false')
  end
end
