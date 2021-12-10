package main

import (
	"flag"
	"log"
	"strings"
	"time"
)

type dayFunc func(string) (int, int)

type challenge struct {
	F        dayFunc
	Input    string
	Examples []string
}

var days = make([]*challenge, 26)

func register(n int, f dayFunc, in string, exs ...string) bool {
	days[n] = &challenge{
		F:        f,
		Input:    strings.TrimSpace(in),
		Examples: exs,
	}
	return true
}

func main() {
	flag.Parse()
	if len(flag.Args()) != 1 {
		log.Fatal("Need to provide day number")
	}
	num := Atoi(flag.Arg(0))
	day := days[num]
	if day == nil {
		log.Fatalf("day %d not defined", num)
	}
	start := time.Now()
	p1, p2 := day.F(day.Input)
	log.Printf("Part 1: %d", p1)
	log.Printf("Part 2: %d", p2)
	log.Println(time.Now().Sub(start))
}
