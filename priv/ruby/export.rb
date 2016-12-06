def sum_two_integers(one, other)
  result = one + other
  Tuple.new(
    [:ok, result]
  )
end
