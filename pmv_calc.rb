
# puts """
# computer program (basic) for calculation of
# predicted mean vote (pmv) and predicted percentage of dissatisfied (ppd)
# in accordance with international standard, iso 7730
# """

# puts "data entry"
# puts "clothing (clo) "; clo = gets
# puts "metabolic rate (met) "; met = gets
# puts "external work, normally around 0 (met) "; wme = gets
# puts "air temperature (°c) "; ta = gets
# puts "mean radiant temperature (°c) "; tr = gets
# puts "relative air velocity (m/s) "; vel = gets
# puts "enter either rh or water vapour pressure but not both"
# puts "relative humidity (%) "; rh = gets
# puts "water vapour pressure (pa) "; pa = gets

class PMVCalc
  def fnps(t)
    Math.exp(16.6536 - 4030.183 / (t + 235)) # saturated vapour pressure, kpa
  end

  def calc(clo, met, wme, ta, tr, vel, rh, pa = 0)
    if pa.zero?
      pa = rh * 10 * fnps(ta) # water vapour pressure, pa
    end

    icl = 0.155 * clo # thermal insulation of the clothing in m 2k/w
    m = met * 58.15 # metabolic rate in w/m 2
    w = wme * 58.15 # external work in w/m 2
    mw = m - w # internal heat production in the human body

    fcl = if icl <= 0.078
            1 + 1.29 * icl
          else
            1.05 + 0.645 * icl # clothing area factor
          end

    hcf = 12.1 * Math.sqrt(vel) # heat transf. coeff. by forced convection
    taa = ta + 273 # air temperature in kelvin
    tra = tr + 273 # mean radiant temperature in kelvin

    #-----calculate surface temperature of clothing by iteration ---

    tcla = taa + (35.5 - ta) / (3.5 * icl + 0.1) # first guess for surface temperature of clothing
    p1 = icl * fcl # calculation term
    p2 = p1 * 3.96 # calculation term
    p3 = p1 * 100 # calculation term
    p4 = p1 * taa # calculation term
    p5 = (308.7 - 0.028 * mw) + (p2 * (tra / 100)**4)
    xn = tcla / 100
    # xf = xn
    xf = tcla / 50

    n = 0 # number of iterations
    eps = 0.00015 # stop criteria in iteration
    hc = nil

    loop do # 350
      xf = (xf + xn) / 2
      hcn = 2.38 * ((100 * xf - taa).abs**0.25) # heat transf. coeff. by natural convection
      hc = if hcf > hcn
             hcf
           else
             hcn
           end
      xn = (p5 + p4 * hc - p2 * xf**4) / (100 + p3 * hc)

      n += 1
      break if (xn - xf).abs <= eps || n > 150
    end

    # if n > 150 then goto 550
    # if abs(xn - xf) > eps goto 350

    tcl = 100 * xn - 273 # surface temperature of the clothing

    # --------------------------------heat loss components -----------------------------------
    hl1 = 3.05 * 0.001 * (5733 - (6.99 * mw) - pa) # heat loss diff. through skin
    hl2 = if mw > 58.15
            0.42 * (mw - 58.15)
          else
            0
          end
    hl3 = 1.7 * 0.00001 * m * (5867 - pa) # latent respiration heat loss
    hl4 = 0.0014 * m * (34 - ta) # dry respiration heat loss
    hl5 = 3.96 * fcl * (xn**4 - (tra / 100)**4) # heat loss by radiation
    hl6 = fcl * hc * (tcl - ta)

    # --------------------------------calculate pmv and ppd -----------------------------------
    ts = 0.303 * Math.exp(-0.036 * m) + 0.028 # thermal sensation trans coeff
    pmv = ts * (mw - hl1 - hl2 - hl3 - hl4 - hl5 - hl6) # predicted mean vote
    ppd = 100 - 95 * Math.exp(-0.03353 * pmv**4 - 0.2179 * pmv**2) # predicted percentage dissat.

    # puts format("pmv calculado\tgabarito\n%.3f\t\t%.3f", pmv, expected_pmv)
    # puts format("ppd calculado\tgabarito\n%.1f\t\t%.1f", ppd, expected_ppd)
    [pmv, ppd]
  end
end
