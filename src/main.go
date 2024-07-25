package main

import (
	"C"
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"
	"unsafe"

	"github.com/erh/gonmea/analyzer"
)

//export enforce_binding
func enforce_binding() {}

func main() {}

//export parse_data
func parse_data(data *C.char, length C.int) *C.char {
	byteArr := C.GoBytes(unsafe.Pointer(data), length)
	fmt.Println(string(byteArr))
	in := io.NopCloser(bytes.NewReader(byteArr))
	defer in.Close()

	parser, err := analyzer.NewParser()
	if err != nil {

		return C.CString(fmt.Sprintf("Error: %v", err))
	}

	reader := bufio.NewReader(in)
	for {
		line, _, err := reader.ReadLine()
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		line = []byte(strings.TrimSpace(string(line)))
		if len(line) == 0 {
			continue
		}
		msg, err := parser.ParseMessage(line)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		md, err := json.MarshalIndent(msg, "", "  ")
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		fmt.Println(string(md))
		return C.CString(string(md))
	}
}
