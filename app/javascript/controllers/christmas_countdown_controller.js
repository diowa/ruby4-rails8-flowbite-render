import { Controller } from "@hotwired/stimulus"

const ROME_TIME_ZONE = "Europe/Rome"
const MILLISECONDS_PER_SECOND = 1000
const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = 60 * SECONDS_PER_MINUTE
const SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR

const romeDateFormatter = new Intl.DateTimeFormat("en-GB", {
  day: "2-digit",
  month: "2-digit",
  timeZone: ROME_TIME_ZONE,
  year: "numeric",
})

const romeDateTimeFormatter = new Intl.DateTimeFormat("en-GB", {
  day: "2-digit",
  hour: "2-digit",
  hourCycle: "h23",
  minute: "2-digit",
  month: "2-digit",
  second: "2-digit",
  timeZone: ROME_TIME_ZONE,
  year: "numeric",
})

function numericParts(formatter, date) {
  return Object.fromEntries(
    formatter
      .formatToParts(date)
      .filter(({ type }) => type !== "literal")
      .map(({ type, value }) => [type, Number(value)]),
  )
}

function timeZoneOffsetAt(timestamp) {
  const parts = numericParts(romeDateTimeFormatter, new Date(timestamp))
  const dateInUtc = Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
  )

  return dateInUtc - timestamp
}

function christmasTimestamp(year) {
  const midnightAsUtc = Date.UTC(year, 11, 25)
  const firstCandidate = midnightAsUtc - timeZoneOffsetAt(midnightAsUtc)

  return midnightAsUtc - timeZoneOffsetAt(firstCandidate)
}

function splitSeconds(totalSeconds) {
  return {
    days: Math.floor(totalSeconds / SECONDS_PER_DAY),
    hours: Math.floor((totalSeconds % SECONDS_PER_DAY) / SECONDS_PER_HOUR),
    minutes: Math.floor((totalSeconds % SECONDS_PER_HOUR) / SECONDS_PER_MINUTE),
    seconds: totalSeconds % SECONDS_PER_MINUTE,
  }
}

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds", "greeting"]

  connect() {
    this.stopTimer()
    this.update()
    this.timer = window.setInterval(() => this.update(), MILLISECONDS_PER_SECOND)
  }

  disconnect() {
    this.stopTimer()
  }

  update() {
    const now = new Date()
    const romeDate = numericParts(romeDateFormatter, now)
    const isChristmasDay = romeDate.month === 12 && romeDate.day === 25
    const targetYear = romeDate.month === 12 && romeDate.day > 25 ? romeDate.year + 1 : romeDate.year
    const remainingSeconds = isChristmasDay
      ? 0
      : Math.max(0, Math.ceil((christmasTimestamp(targetYear) - now.getTime()) / MILLISECONDS_PER_SECOND))

    this.render(splitSeconds(Number.isFinite(remainingSeconds) ? remainingSeconds : 0), isChristmasDay)
  }

  render(remaining, isChristmasDay) {
    this.daysTarget.textContent = String(remaining.days)
    this.hoursTarget.textContent = String(remaining.hours).padStart(2, "0")
    this.minutesTarget.textContent = String(remaining.minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(remaining.seconds).padStart(2, "0")
    this.greetingTarget.hidden = !isChristmasDay
  }

  stopTimer() {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = undefined
    }
  }
}
