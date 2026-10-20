import time
def suma(n):
    total = 0
    for i in range(n):
        total += i % 7
    return total
t0=time.perf_counter(); r=0
for k in range(2000):
    r += suma(100_000)
print("resultado=%d tiempo=%d ms"%(r,(time.perf_counter()-t0)*1000))
