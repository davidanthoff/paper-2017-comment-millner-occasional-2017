using Interpolations
using Plots
using StatPlots

include("mimi-dice-2013/src/marginaldamage.jl")

m1, m2 = getmarginal_dice_models()

run(m1)
run(m2)

md = m2[:damages, :DAMAGES] .- m1[:damages, :DAMAGES]
md_yearly = repeat(md, inner=5)
cpc_yearly = repeat(m1[:neteconomy, :CPC], inner=5)

T = 200
η = 1.5
ρ = 0.015

df_bill = [(cpc_yearly[1] / cpc_yearly[t])^η * (1+ρ)^(-(t-1)) for t=1:T]
df_epa = [(1+0.03)^(-(t-1)) for t in 1:T]

raw_x_1_max = readcsv("../data/x_1_max.csv")
raw_x_1_min = readcsv("../data/x_1_min.csv")

raw_x_1_over_N_max = readcsv("../data/x_1_over_N_max.csv")
raw_x_1_over_N_min = readcsv("../data/x_1_over_N_min.csv")

raw_x_90_max = readcsv("../data/x_90_max.csv")
raw_x_90_min = readcsv("../data/x_90_min.csv")


df_antony_x_1_max = interpolate((raw_x_1_max[:,1],), raw_x_1_max[:,2], Gridded(Linear()))
df_antony_x_1_min = interpolate((raw_x_1_min[:,1],), raw_x_1_min[:,2], Gridded(Linear()))

df_antony_x_1_over_N_max = interpolate((raw_x_1_over_N_max[:,1],), raw_x_1_over_N_max[:,2], Gridded(Linear()))
df_antony_x_1_over_N_min = interpolate((raw_x_1_over_N_min[:,1],), raw_x_1_over_N_min[:,2], Gridded(Linear()))

df_antony_x_90_max = interpolate((raw_x_90_max[:,1],), raw_x_90_max[:,2], Gridded(Linear()))
df_antony_x_90_min = interpolate((raw_x_90_min[:,1],), raw_x_90_min[:,2], Gridded(Linear()))

npv_md_bill = md_yearly[1:T] .* df_bill
npv_md_epa = md_yearly[1:T] .* df_epa
npv_md_antony_x_1_max = [md_yearly[t] * (1 + df_antony_x_1_max[t-1]/100)^(-(t-1)) for t=1:T]
npv_md_antony_x_1_min = [md_yearly[t] * (1 + df_antony_x_1_min[t-1]/100)^(-(t-1)) for t=1:T]
npv_md_antony_x_1_over_N_max = [md_yearly[t] * (1 + df_antony_x_1_over_N_max[t-1]/100)^(-(t-1)) for t=1:T]
npv_md_antony_x_1_over_N_min = [md_yearly[t] * (1 + df_antony_x_1_over_N_min[t-1]/100)^(-(t-1)) for t=1:T]
npv_md_antony_x_90_max = [md_yearly[t] * (1 + df_antony_x_90_max[t-1]/100)^(-(t-1)) for t=1:T]
npv_md_antony_x_90_min = [md_yearly[t] * (1 + df_antony_x_90_min[t-1]/100)^(-(t-1)) for t=1:T]

const emission_pulse = 10^9 * 5
const dollar_scalar = 10^12

scc_bill = sum(npv_md_bill) / emission_pulse * dollar_scalar
scc_epa = sum(npv_md_epa) / emission_pulse * dollar_scalar
scc_antony_x_1_max = sum(npv_md_antony_x_1_max) / emission_pulse * dollar_scalar
scc_antony_x_1_min = sum(npv_md_antony_x_1_min) / emission_pulse * dollar_scalar
scc_antony_x_1_over_N_max = sum(npv_md_antony_x_1_over_N_max) / emission_pulse * dollar_scalar
scc_antony_x_1_over_N_min = sum(npv_md_antony_x_1_over_N_min) / emission_pulse * dollar_scalar
scc_antony_x_90_max = sum(npv_md_antony_x_90_max) / emission_pulse * dollar_scalar
scc_antony_x_90_min = sum(npv_md_antony_x_90_min) / emission_pulse * dollar_scalar

println("")

boxplot(["Nordhaus", "EPA", "x=1", "x=1", "x=1/N", "x=1/N", "x=90%", "x=90%"],
    [scc_bill, scc_epa, scc_antony_x_1_min, scc_antony_x_1_max,
    scc_antony_x_1_over_N_min, scc_antony_x_1_over_N_max,
    scc_antony_x_90_min, scc_antony_x_90_max])
