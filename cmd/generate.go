// Copyright © 2018 Tobias Brunner <tobias.brunner@vshn.ch>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

package cmd

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"text/template"
	"time"

	"github.com/spf13/cobra"
)

type jobParameters struct {
	Volumes []string
	Date    time.Time
}

// generateCmd represents the generate command
var generateCmd = &cobra.Command{
	Use:   "generate",
	Short: "Backup job generator",
	Long:  `A backup job generator`,

	Run: func(cmd *cobra.Command, args []string) {
		generateJob(cmd, args)
	},
}

func init() {
	jobCmd.AddCommand(generateCmd)
}

func formatAsDate(t time.Time) string {
	year, month, day := t.Date()
	hour, minute, second := t.Clock()
	return fmt.Sprintf("%d%d%d%d%d%d", year, month, day, hour, minute, second)
}

func cleanupJob(keep int) {
	fmt.Println("cleanup called for namespace", namespace)

	ocCmd := exec.Command("oc", "-n", namespace, "get", "jobs", "-o", "name", "-l", "baas=backupjob")
	ocOut, err := ocCmd.Output()
	if err != nil {
		panic(err)
	}

	// collect Jobs into a slice
	var jobs []string

	// read through every line of the output
	scanner := bufio.NewScanner(strings.NewReader(string(ocOut)))
	for scanner.Scan() {
		// add name to slice
		jobs = append(jobs, scanner.Text())
	}

	// if more than configured jobs found - delete old onews
	if len(jobs) > keep {
		fmt.Printf("More than %d backup jobs found %d - deleting oldest\n", keep, len(jobs))
		for len(jobs) > keep {
			j := jobs[0]
			jobs = jobs[1:]
			fmt.Println("Deleting", j)

			ocCmd := exec.Command("oc", "-n", namespace, "delete", j)
			_, err := ocCmd.Output()
			if err != nil {
				panic(err)
			}
		}
	}
	for _, v := range jobs {
		fmt.Println("Keeping", v)
	}
}

func generateJob(cmd *cobra.Command, args []string) {
	namespace := cmd.Flag("namespace").Value.String()
	fmt.Println("generate called for namespace", namespace)
	// TODO label filter
	ocCmd := exec.Command("oc", "-n", namespace, "get", "pvc", "-o", "name")
	ocOut, err := ocCmd.Output()
	if err != nil {
		panic(err)
	}

	// collect PVC names into a slice
	var pvcs []string

	// read through every line of the output
	scanner := bufio.NewScanner(strings.NewReader(string(ocOut)))
	for scanner.Scan() {
		// remove persistentvolumeclaims/ from the output
		name := strings.Replace(scanner.Text(), "persistentvolumeclaims/", "", -1)
		// add name to slice
		pvcs = append(pvcs, name)
		fmt.Println("Processing PVC:", name)
	}

	// if no PVCs are found, no job has to be generated
	if len(pvcs) == 0 {
		fmt.Println("no PVCs found in namespace", namespace)
	} else {
		// there are PVCs to backup
		fmt.Println("Number of PVCs found:", len(pvcs))

		// Prepare job template
		fmap := template.FuncMap{
			"formatAsDate": formatAsDate,
		}

		// Create a new template
		t := template.Must(template.New("job-backup.tpl").Funcs(fmap).ParseFiles("templates/job-backup.tpl"))

		// Generate the job template
		var job bytes.Buffer
		err := t.Execute(&job, &jobParameters{
			Volumes: pvcs,
			Date:    time.Now(),
		})
		if err != nil {
			panic(err)
		}

		//fmt.Println(job.String())
		ocApply := exec.Command("oc", "-n", namespace, "apply", "-f", "-")
		ocApply.Stdout = os.Stdout
		ocApply.Stdin = &job
		ocApply.Stderr = os.Stderr
		err = ocApply.Run()
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
		} else {
			fmt.Fprintln(os.Stdout)
		}

		fmt.Println("cleaning up jobs")
		cleanupJob(2)
	}
}
