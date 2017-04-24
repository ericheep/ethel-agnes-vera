import matplotlib.pyplot as plt
import numpy as np

len = np.arange(25)

fanCase = [36.5, 49.9, 53.7, 55.8,
           57.5, 58.5, 58.5, 59.6,
           60.1, 60.1, 60.7, 61.2,
           61.2, 61.8, 61.8, 62.3,
           62.3, 62.3, 62.8, 62.3,
           62.3, 62.3, 62.3, 62.3, 62.3]

noCooling = [42.9, 55.8, 60.1, 63.4,
             65.5, 66.6, 67.7, 69.8,
             70.4, 71.4, 72.0, 73.1,
             73.6, 74.1, 75.2, 75.2,
             75.8, 76.3, 77.4, 77.4,
             77.4, 77.4, 78.4, 78.4, 79.5]

heatSink = [42.9, 51.5, 54.2, 56.9,
            58.0, 60.1, 61.2, 63.4,
            63.9, 64.5, 65.5, 66.6,
            67.7, 68.2, 69.3, 69.8,
            70.9, 70.9, 71.4, 72.0,
            72.0, 72.5, 73.6, 73.1, 74.1]

heatSinkFanCase = [37.0, 45.1, 47.2, 48.3,
                   49.9, 51.0, 52.1, 52.6,
                   52.6, 53.7, 53.7, 53.7,
                   53.7, 53.7, 53.7, 54.8,
                   53.7, 54.8, 54.8, 54.8,
                   55.3, 54.8, 54.8, 54.8, 54.2]


def timeConversion(seconds):
    m, s = divmod(seconds, 60)
    return(str(m) + ":" + str(s))

labels = [timeConversion(i) for i in len * 15]

print(labels)

plt.plot(noCooling, label="No Cooling")
plt.plot(heatSink, label="Heat Sink")
plt.plot(fanCase, label="Fan Case")
plt.plot(heatSinkFanCase, label="Fan Case With Heat Sink")

plt.legend(loc=4)
plt.ylabel("Temperature (Celcius)")
plt.xlabel("Seconds")
plt.xticks(len, labels)
plt.xlim(0, 24)

plt.show()
