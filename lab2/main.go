package main

import (
	"bytes"
	"encoding/csv"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"sort"
	"strconv"
	"strings"
)

func errh(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

type task struct {
	out string
	ts  TS
}
type TS struct {
	s2, s3, s4 string
}

func main() {
	parallels := []string{"task1_1_1_tcp.csv",
		"task1_1_1_udp.csv",
		"task1_1_2_server2.csv",
		"task1_1_2_server3.csv",
		"task1_1_2_server4.csv",
		"task1_2_server2.csv",
		"task1_2_server3.csv",
		"task1_2_server4.csv",
		"task1_3_2_server2.csv",
		"task1_3_2_server3.csv",
		"task1_3_2_server4.csv",
		"task1_3_3_server2.csv",
		"task1_3_3_server3.csv",
		"task1_3_3_server4.csv",
		"task2_server2_nopri.csv",
		"task2_server3_nopri.csv",
		"task2_server2_pri.csv",
		"task2_server3_pri.csv",
	}
	for _, file := range parallels {
		sumcsv(file)
	}
	// singles := []string{
	// 	"task1_3_2_server2.csv",
	// 	"task1_3_2_server3.csv",
	// 	"task1_3_2_server4.csv",
	// }
	// for _, file := range singles {
	// 	simplecsv(file)
	// }
	err := exec.Command("./plot.gnu").Run()
	if err != nil {
		log.Println(err)
	}

	t1 := task{"./lab2-group5-task1.1.1.csv", TS{"./task1_1_1_tcp.csv", "./task1_1_1_udp.csv", ""}}
	tcp, udp := csvsum(t1.ts.s2), csvsum(t1.ts.s3)
	out := make([][]string, 1, len(tcp)+1)
	out[0] = []string{"time", "tcp", "udp"}
	for i := range tcp {
		out = append(out, []string{strconv.Itoa(i), tcp[i][1], udp[i][1]})
	}
	writecsv(t1.out, out)

	filesets := []task{
		{"./lab2-group5-task1.1.2.csv", TS{"./task1_1_2_server2.csv", "./task1_1_2_server3.csv", "./task1_1_2_server4.csv"}},
		{"./lab2-group5-task1.2.csv", TS{"./task1_2_server2.csv", "./task1_2_server3.csv", "./task1_2_server4.csv"}},
		{"./lab2-group5-task1.3.2.csv", TS{"./task1_3_2_server2.csv", "./task1_3_2_server3.csv", "./task1_3_2_server4.csv"}},
		{"./lab2-group5-task1.3.3.csv", TS{"./task1_3_3_server2.csv", "./task1_3_3_server3.csv", "./task1_3_3_server4.csv"}},
		{"./lab2-group5-task2-pri.csv", TS{"./task2_server2_pri.csv", "./task2_server3_pri.csv", ""}},
		{"./lab2-group5-task2-nopri.csv", TS{"./task2_server2_nopri.csv", "./task2_server3_nopri.csv", ""}},
	}
	for _, task := range filesets {
		files := task.ts
		res := map[string]TS{}

		rr := csvsum(files.s2)
		for _, r := range rr {
			t := res[r[0]]
			t.s2 = r[1]
			res[r[0]] = t
		}
		rr = csvsum(files.s3)
		for _, r := range rr {
			t := res[r[0]]
			t.s3 = r[1]
			res[r[0]] = t
		}
		if files.s4 != "" {
			rr = csvsum(files.s4)
			for _, r := range rr {
				t := res[r[0]]
				t.s4 = r[1]
				res[r[0]] = t
			}
		}

		tss := make([]string, 0, len(res))
		for k := range res {
			tss = append(tss, k)
		}
		sort.Strings(tss)
		data := make([][]string, 1, len(tss)+1)
		data[0] = []string{"time", "server2", "server3", "server4"}

		for i, k := range tss {
			row := []string{strconv.Itoa(i), res[k].s2, res[k].s3, res[k].s4}
			for j, v := range row {
				if v == "" {
					row[j] = "-"
				}
			}
			data = append(data, row)
		}

		writecsv(task.out, data)
	}
}

func simplecsv(fn string) {
	f, err := os.Open(fn)
	errh(err)
	defer f.Close()

	r := csv.NewReader(f)
	rows, err := r.ReadAll()
	errh(err)

	var buf bytes.Buffer
	for _, row := range rows {
		buf.WriteString(strings.ReplaceAll(row[0], ".", "") + " " + row[8] + "\n")
	}

	of := strings.ReplaceAll(fn, "task", "out")
	err = ioutil.WriteFile(of, buf.Bytes(), 0644)
	errh(err)
}

func sumcsv(fn string) {
	f, err := os.Open(fn)
	errh(err)
	defer f.Close()

	r := csv.NewReader(f)
	rows, err := r.ReadAll()
	errh(err)

	var buf bytes.Buffer
	for _, row := range rows {
		if row[5] == "-1" {
			buf.WriteString(strings.ReplaceAll(row[0], ".", "") + " " + row[8] + "\n")
		}
	}

	of := strings.ReplaceAll(fn, "task", "out")
	err = ioutil.WriteFile(of, buf.Bytes(), 0644)
	errh(err)
}

func csvsum(fn string) [][]string {
	f, err := os.Open(fn)
	errh(err)
	defer f.Close()

	r := csv.NewReader(f)
	rows, err := r.ReadAll()
	errh(err)

	res := make([][]string, 0, 300)
	for _, row := range rows {
		if row[5] == "-1" {
			res = append(res, []string{row[0][:16], row[8]})
		}
	}
	return res
}
func writecsv(fn string, data [][]string) {
	f, err := os.Create(fn)
	errh(err)
	defer f.Close()

	w := csv.NewWriter(f)
	w.WriteAll(data)
	w.Flush()
}
