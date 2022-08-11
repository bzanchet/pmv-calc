require 'minitest/autorun'
require_relative '../pmv_calc'

class TestMeme < Minitest::Test
  def test_sample_results_from_iso
    sample_results = [
      [22.0, 22.0, 0.10, 60, 1.2, 0.5, -0.75, 17],
      [27.0, 27.0, 0.10, 60, 1.2, 0.5, 0.77, 17],
      [27.0, 27.0, 0.30, 60, 1.2, 0.5, 0.44, 9],
      [23.5, 25.5, 0.10, 60, 1.2, 0.5, -0.01, 5],
      [23.5, 25.5, 0.30, 60, 1.2, 0.5, -0.55, 11],
      [19.0, 19.0, 0.10, 40, 1.2, 1.0, -0.60, 13],
      [23.5, 23.5, 0.10, 40, 1.2, 1.0, 0.50, 10],
      [23.5, 23.5, 0.30, 40, 1.2, 1.0, 0.12, 5],
      [23.0, 21.0, 0.10, 40, 1.2, 1.0, 0.05, 5],
      [23.0, 21.0, 0.30, 40, 1.2, 1.0, -0.16, 6],
      [22.0, 22.0, 0.10, 60, 1.6, 0.5, 0.05, 5],
      [27.0, 27.0, 0.10, 60, 1.6, 0.5, 1.17, 34],
      [27.0, 27.0, 0.30, 60, 1.6, 0.5, 0.95, 24]
    ]
    sample_results.each do |value|
      wme, pa = 0
      ta, tr, vel, rh, met, clo, expected_pmv, expected_ppd = value
      pmv, ppd = PMVCalc.new.calc(clo, met, wme, ta, tr, vel, rh)

      puts format("asserting %.2f and #{expected_pmv}", pmv)
      assert_in_delta expected_pmv, pmv, 0.2
      puts format("asserting %.2f and #{expected_ppd}", ppd)

      assert_in_delta expected_ppd, ppd, 5
    end
  end
end
