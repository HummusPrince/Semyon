def tidybyte(i):
    return "0x" + hex(i)[2:].zfill(2)

if __name__ == "__main__":
    #dnum points of 255*exp(-x/t)
    dnum = 512
    t = 8/dnum
    if dnum <= 128:
        pwmvals = [int(255*(0.5**(x*t))) for x in range(dnum)]
    else:
        pwmvals = [max(int(127*(0.5**(x*t))) << 1, 1) for x in range(dnum)]
    val_cnt = [(i, pwmvals.count(i)) for i in sorted(list(set(pwmvals)))]

    f = open("pwm_tbl.txt",'w')
    f.write("; pwmval, duration\n")
    for (val, cnt) in val_cnt:
        f.write(".db " + tidybyte(val) + ", " + tidybyte(cnt) + "\n")
    print('done')
    f.close()