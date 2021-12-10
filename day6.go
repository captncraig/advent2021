package main

func day6(input string) (p1Result, p2Result int) {
	fish := IntsCSV(input)

	counts := map[int]int{}
	for _, f := range fish {
		counts[f]++
	}

	for d := 0; d < 256; d++ {
		//log.Println(d, counts)
		zeros := counts[0]
		for i := 1; i <= 8; i++ {
			counts[i-1] = counts[i]
		}
		counts[6] += zeros
		counts[8] = zeros
		if d == 79 {
			for _, c := range counts {
				p1Result += c
			}
		}
	}
	for _, c := range counts {
		p2Result += c
	}
	return
}

var _ = register(6, day6, `3,4,1,2,1,2,5,1,2,1,5,4,3,2,5,1,5,1,2,2,2,3,4,5,2,5,1,3,3,1,3,4,1,5,3,2,2,1,3,2,5,1,1,4,1,4,5,1,3,1,1,5,3,1,1,4,2,2,5,1,5,5,1,5,4,1,5,3,5,1,1,4,1,2,2,1,1,1,4,2,1,3,1,1,4,5,1,1,1,1,1,5,1,1,4,1,1,1,1,2,1,4,2,1,2,4,1,3,1,2,3,2,4,1,1,5,1,1,1,2,5,5,1,1,4,1,2,2,3,5,1,4,5,4,1,3,1,4,1,4,3,2,4,3,2,4,5,1,4,5,2,1,1,1,1,1,3,1,5,1,3,1,1,2,1,4,1,3,1,5,2,4,2,1,1,1,2,1,1,4,1,1,1,1,1,5,4,1,3,3,5,3,2,5,5,2,1,5,2,4,4,1,5,2,3,1,5,3,4,1,5,1,5,3,1,1,1,4,4,5,1,1,1,3,1,4,5,1,2,3,1,3,2,3,1,3,5,4,3,1,3,4,3,1,2,1,1,3,1,1,3,1,1,4,1,2,1,2,5,1,1,3,5,3,3,3,1,1,1,1,1,5,3,3,1,1,3,4,1,1,4,1,1,2,4,4,1,1,3,1,3,2,2,1,2,5,3,3,1,1`)
