require 'rubygems'
require 'erlectricity'

receive do |f|
  f.when([:sum_two_integers, Integer, Integer]) do |a, b|
    f.send!([:result, [:ok, a+b]])
    f.receive_loop
  end
end
