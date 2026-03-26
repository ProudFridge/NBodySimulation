import matplotlib.pyplot as plt

xValues = []
yValues = []

with open("values.csv", "r") as file:
    for line in file:
        content = line.split(",")
        yValues.append(float(content[1]))
        xValues.append(float(content[0]))

# plt.semilogy(xValues , yValues)
plt.plot(xValues , yValues)
plt.xlabel('Time')
plt.ylabel('|(E(t)-E0)/E0|')
plt.show()

# Save the plot as a PDF  
# plt.savefig("plot.pdf", format="pdf")  
print("hifdsii")