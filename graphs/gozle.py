import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

df = pd.read_csv('barlag24.csv', sep=',')
print(np.shape(df))

# Calculate the average
df['aver'] = (df['sum']) / (df['pcount'])

blue_patch = mpatches.Patch(color='blue', label='Average enq depth / packets graph')
red_patch = mpatches.Patch(color='red', label='Min enq depth graph')
green_patch = mpatches.Patch(color='green', label='Max enq depth graph')
plt.legend(handles=[blue_patch,red_patch,green_patch])
plt.xlabel('Time in seconds ', fontsize=16)
plt.ylabel('Average enq depth / packets ', fontsize=16)

x_axis = range(len(df['pcount']))
df['time']= range(len(df['pcount']))
print(df['time'])
plt.scatter(x_axis, df['max'],color='green',alpha=0.5)
plt.scatter(x_axis, df['aver'],color='blue',alpha=0.5)
plt.scatter(x_axis, df['min'],color='red',alpha=0.5)
print(df['pcount'])
plt.xticks([0, 200, 400, 600, 800, 1000],
           [0, int(df['time'][200]/10), int(df['time'][400]/10),int(df['time'][600]/10),
            int(df['time'][800]/10),int(df['time'][1000]/10)])
plt.savefig("temp.png")
plt.show()
