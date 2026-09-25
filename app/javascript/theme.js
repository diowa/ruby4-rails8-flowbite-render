const preference = window.matchMedia('(prefers-color-scheme: dark)')

function applyTheme() {
  const savedTheme = localStorage.getItem('theme')
  const isDark = savedTheme === 'dark' || (savedTheme === null && preference.matches)

  document.documentElement.classList.toggle('dark', isDark)
  document.querySelectorAll('[data-theme-toggle]').forEach((button) => {
    button.setAttribute('aria-pressed', String(isDark))
    button.setAttribute('aria-label', `Switch to ${isDark ? 'light' : 'dark'} theme`)
  })
}

applyTheme()

preference.addEventListener('change', () => {
  if (localStorage.getItem('theme') === null) applyTheme()
})

document.addEventListener('click', (event) => {
  if (!event.target.closest('[data-theme-toggle]')) return

  localStorage.setItem('theme', document.documentElement.classList.contains('dark') ? 'light' : 'dark')
  applyTheme()
})

document.addEventListener('DOMContentLoaded', applyTheme)
document.addEventListener('turbo:render', applyTheme)
