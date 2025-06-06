#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot, chart
#import "@preview/numty:0.0.5" as nt

#let SURNAME_NAME = "Никитин Илья"
#let UNN_GROUP = "3822Б1МА1"

/// Общее ограничение на количество итераций.
#let ITER_LIMIT = 50

/// Общее ограничение на точность.
#let EPS = 1e-5

// Определение функций уравнений
#let f1(x) = x * x * x - x
#let f2(x) = x * x * x - 3 * x * x + 6 * x - 5
#let f3(x) = x - calc.sin(x) - 0.25
#let f4(x) = x - calc.sin(calc.pi / 2 * x) - 0.25
#let f5(x) = x - calc.cos(x)
#let f6(x) = x - calc.cos(calc.pi / 2 * x)

// Производные для метода Ньютона
#let df1(x) = 3 * x * x - 1
#let df2(x) = 3 * x * x - 6 * x + 6
#let df3(x) = 1 - calc.cos(x)
#let df4(x) = 1 - calc.pi / 2 * calc.cos(calc.pi / 2 * x)
#let df5(x) = 1 + calc.sin(x)
#let df6(x) = 1 + calc.pi / 2 * calc.sin(calc.pi / 2 * x)

// Функции phi(x) для метода простой итерации
#let phi_f1(x) = if x < 0 { x } else { calc.pow(x, 1 / 3) }
#let phi_f2(x) = (-x * x * x + 3 * x * x + 5) / 6
#let phi_f3(x) = calc.sin(x) + 0.25
#let phi_f4(x) = calc.sin(calc.pi / 2 * x) + 0.25
#let phi_f5(x) = calc.cos(x)
#let phi_f6(x) = calc.cos(calc.pi / 2 * x)

// Производные phi(x)
#let dphi_f1(x) = 1.0 / (3.0 * calc.pow(x, 2.0 / 3.0))
#let dphi_f2(x) = (-2 * x * x + 6 * x) / 6
#let dphi_f3(x) = calc.cos(x)
#let dphi_f4(x) = calc.pi / 2 * calc.cos(calc.pi / 2 * x)
#let dphi_f5(x) = -calc.sin(x)
#let dphi_f6(x) = -calc.pi / 2 * calc.sin(calc.pi / 2 * x)

/// Метод половинного деления
#let bisection(a, b, f, eps: EPS, max-iter: ITER_LIMIT) = {
  let hist = ()
  if f(a) * f(b) >= 0 { return hist }
  for i in range(max-iter) {
    let c = (a + b) / 2
    hist.push(c)
    if f(c) == 0 or (b - a) / 2 < eps { break }
    if f(c) * f(a) < 0 { b = c } else { a = c }
  }
  hist
}

/// Метод хорд
#let chord(a, b, f, eps: EPS, max-iter: ITER_LIMIT) = {
  let hist = ()
  for i in range(max-iter) {
    let c = a - f(a) * (b - a) / (f(b) - f(a))
    hist.push(c)
    if calc.abs(f(c)) < eps { break }
    if f(c) * f(a) < 0 { b = c } else { a = c }
  }
  hist
}

/// Метод простой итерации
#let simple-iter(x0, phi, eps: EPS, max-iter: ITER_LIMIT) = {
  let hist = (x0,)
  let converged = false
  for i in range(max-iter) {
    let x = phi(hist.at(-1))
    hist.push(x)
    if calc.abs(hist.at(-1) - hist.at(-2)) < eps {
      converged = true
      break
    }
  }
  (hist, converged)
}

/// Метод Ньютона
#let newton(x0, f, df, eps: EPS, max-iter: ITER_LIMIT) = {
  let hist = (x0,)
  for i in range(max-iter) {
    let dfx = df(hist.at(-1))
    if calc.abs(dfx) < 1e-12 { break }
    let delta = f(hist.at(-1)) / dfx
    hist.push(hist.at(-1) - delta)
    if calc.abs(delta) < eps { break }
  }
  hist
}

/// Проверка сходимости метода простой итерации
/// |φ'(x)| < 1 на [a, b].
#let check-convergence-simple(dphi, a, b) = {
  let steps = 10
  let step = (b - a) / steps
  for i in range(steps + 1) {
    let x = a + i * step
    if calc.abs(dphi(x)) >= 1.0 { return false }
  }
  true
}

/// Проверка достаточного условия сходимости метода Ньютона
/// 1. f(a) * f(b) < 0
/// 2. f'(x) и f''(x) одного знака на [a, b]
/// 3. f(x0) * f''(x0) > 0
#let check-convergence-newton(f, df, ddf, a, b, x0) = {
  // 1.
  if f(a) * f(b) >= 0 { return false }
  // 2.
  let steps = 10
  let step = (b - a) / steps
  let sign_df = df(a).signum()
  let sign_ddf = ddf(a).signum()
  for i in range(steps + 1) {
    let x = a + i * step
    if df(x).signum() != sign_df or ddf(x).signum() != sign_ddf { return false }
    if df(x) == 0 { return false }
  }
  // 3.
  if f(x0) * ddf(x0) <= 0 { return false }
  true
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#let double-line = block(width: 100%)[
  #block(spacing: 0pt, line(length: 100%))
  #v(2.5pt)
  #block(spacing: 0pt, line(length: 100%))
]
#set page(
  height: auto,
  width: 50em,
  margin: (top: 3em, rest: 0.5cm),
  header: [
    ЛР.02.
    #h(1fr)
    #SURNAME_NAME,
    #h(1pt)
    #UNN_GROUP
  ],
)
#set par(justify: true)
#show par: it => align(center, it)
#set table(stroke: 0.3pt)
#show heading: it => align(center, box(inset: 8pt, stroke: 1pt, it))
#show heading.where(level: 2): it => align(
  center,
  grid(
    columns: (1fr, auto, 1fr),
    align: horizon + center,
    column-gutter: 5pt,
    double-line, it.body, double-line,
  ),
)
#show table.cell.where(x: 0): strong
#show table.cell.where(y: 0): strong

#let PLOT_SCALE = 7
#let COLORS = (
  rgb(200, 0, 0),
  rgb(0, 130, 0),
  rgb(0, 0, 200),
  rgb(160, 0, 160),
)
#let tick-fmt(x) = {
  set text(size: 8pt)
  calc.round(x, digits: 13)
}

#let show-function-plot(func, points-data) = {
  let a = calc.min(..points-data.map(((pts, _, _)) => pts).flatten()) - 0.02
  let b = calc.max(..points-data.map(((pts, _, _)) => pts).flatten()) + 0.02
  cetz.canvas({
    cetz.draw.set-style(
      axes: (
        stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
        tick: (stroke: gray + .5pt),
      ),
      legend: (stroke: none),
    )
    plot.plot(
      size: (PLOT_SCALE, PLOT_SCALE),
      x-label: $x$,
      y-label: $f(x)$,
      axis-style: "school-book",
      x-format: tick-fmt,
      y-format: tick-fmt,
      legend: "south",
      {
        plot.add(func, domain: (a, b), style: (stroke: black + 0.2pt))
        for (points, name, color) in points-data {
          plot.add(
            points.map(x => (x, func(x))),
            mark: "o",
            mark-size: 0.1,
            style: (stroke: color + 0.5pt),
            label: name,
          )
        }
      },
    )
  })
}

#let show-error-plot(error-data) = cetz.canvas({
  cetz.draw.set-style(
    axes: (
      stroke: (paint: gray, dash: "solid", thickness: 0.1mm),
      tick: (stroke: gray + .5pt),
    ),
    legend: (stroke: none),
  )
  plot.plot(
    size: (PLOT_SCALE, PLOT_SCALE),
    x-label: $i$,
    y-label: $|x_i - x^*|$,
    axis-style: "school-book",
    x-format: tick-fmt,
    y-format: tick-fmt,
    legend: "south",
    {
      for (i, (points, name)) in error-data.enumerate() {
        plot.add(
          points,
          style: (stroke: COLORS.at(i) + 1pt),
          mark: "o",
          mark-size: 0.05,
          label: name,
        )
      }
    },
  )
})

#let show-overview-table(histories, x-ref) = table(
  columns: (auto, auto, auto, 1fr),
  align: center,
  [*Метод*], [*Итерации*], [*Приближение корня*], [*Погрешность*],
  ..(
    for (hist, name, _) in histories {
      let iterations = hist.len() - 1
      let final-x = hist.at(-1)
      let error = calc.abs(final-x - x-ref)
      (name, iterations, final-x, error).map(x => [#x])
    }
  )
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

== Задание 1

Найти корень уравнения $f(x) = x^3 - x$ на отрезке $[0.5; 2]$.

#let func = f1
#let dfunc = df1
#let phifunc = phi_f1
#let dphifunc = dphi_f1
#let a = 0.5
#let b = 2.0

#let x-ref = 1
#let bisect-hist = bisection(a, b, func)
#let chord-hist = chord(a, b, func)
#let (si-hist, si-converged) = simple-iter((a + b) / 2, phifunc)
#let newton-hist = newton((a + b) / 2, func, dfunc)

#let plot-data = (
  (bisect-hist, "Половинного деления", COLORS.at(0)),
  (chord-hist, "Хорд", COLORS.at(1)),
  (si-hist, "Простой итерации", COLORS.at(2)),
  (newton-hist, "Ньютона", COLORS.at(3)),
)

#let error-data = plot-data.map(((hist, name, _)) => (
  hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
  name,
))

#grid(
  columns: 2,
  align: center + horizon,
  show-function-plot(func, plot-data), show-error-plot(error-data),
)

#align(center, show-overview-table(plot-data, x-ref))


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

== Задание 2

Найти другие корни уравнения $f(x) = x^3 - x$.

#let intervals = ((-0.3, 0.5), (-2.0, -0.5))
#let roots = (0, -1)

#for (k, (a, b)) in intervals.enumerate() {
  [=== Корень на отрезке $[#a; #b]$]

  let x-ref = roots.at(k)
  let bisect-hist = bisection(a, b, func)
  let chord-hist = chord(a, b, func)
  let (si-hist, si-converged) = simple-iter(a, phifunc)
  let newton-hist = newton(a, func, dfunc)

  let plot-data = (
    (bisect-hist, "Половинного деления", COLORS.at(0)),
    (chord-hist, "Хорд", COLORS.at(1)),
    (si-hist, "Простой итерации", COLORS.at(2)),
    (newton-hist, "Ньютона", COLORS.at(3)),
  )

  let error-data = plot-data.map(((hist, name, _)) => (
    hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
    name,
  ))

  grid(
    columns: 2,
    align: center + horizon,
    show-function-plot(func, plot-data), show-error-plot(error-data),
  )

  align(center, show-overview-table(plot-data, x-ref))
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

== Задание 3

Найти корень в каждом из уравнений 2-6.

// Add second derivatives for Newton's method
#let ddf1(x) = 6 * x
#let ddf2(x) = 6 * x - 6
#let ddf3(x) = calc.sin(x)
#let ddf4(x) = (calc.pi / 2) * (calc.pi / 2) * calc.sin(calc.pi / 2 * x)
#let ddf5(x) = calc.cos(x)
#let ddf6(x) = (calc.pi / 2) * (calc.pi / 2) * calc.cos(calc.pi / 2 * x)

#let functions = (
  (f2, df2, ddf2, phi_f2, dphi_f2, "x^3 - 3x^2 + 6x - 5", (0.5, 2.0), 1.3221853546260855929114707107040320),
  (f3, df3, ddf3, phi_f3, dphi_f3, "x - sin(x) - 0.25", (1.0, 1.5), 1.171229652501665993903833075536210572017),
  (f4, df4, ddf4, phi_f4, dphi_f4, "x - sin(pi/2 x) - 0.25", (1.0, 1.5), 1.2007108667632066604),
  (f5, df5, ddf5, phi_f5, dphi_f5, "x - cos(x)", (0.5, 1.5), 0.7390851332151606416553120876738734040134),
  (f6, df6, ddf6, phi_f6, dphi_f6, "x - cos(pi/2 x)", (0.5, 1.0), 0.5946116384296164),
)

#for (func, dfunc, ddfunc, phifunc, dphifunc, name, (a, b), root) in functions {
  [=== Уравнение $f(x) = #eval(mode: "math", name)$]

  let x0 = (a + b) / 2
  let x-ref = root
  let bisect-hist = bisection(a, b, func)
  let chord-hist = chord(a, b, func)
  let (si-hist, si-converged) = simple-iter(x0, phifunc)
  let newton-hist = newton(x0, func, dfunc)

  let plot-data = (
    (bisect-hist, "Половинного деления", COLORS.at(0)),
    (chord-hist, "Хорд", COLORS.at(1)),
    (si-hist, "Простой итерации", COLORS.at(2)),
    (newton-hist, "Ньютона", COLORS.at(3)),
  )

  let error-data = plot-data.map(((hist, name, _)) => (
    hist.enumerate().map(((i, x)) => (i, calc.abs(x - x-ref))),
    name,
  ))

  grid(
    columns: 2,
    align: center + horizon,
    show-function-plot(func, plot-data), show-error-plot(error-data),
  )

  align(center, show-overview-table(plot-data, x-ref))

  if check-convergence-simple(dphifunc, a, b) {
    [Метод простой итерации сходится на данном отрезке.]
  } else {
    [Метод простой итерации не сходится на данном отрезке.]
  }
  parbreak()
  if check-convergence-newton(func, dfunc, ddfunc, a, b, x0) {
    [Метод Ньютона сходится на данном отрезке (достаточное условие).]
  } else {
    [Метод Ньютона не гарантированно сходится на данном отрезке (достаточное условие не выполнено).]
  }
}
