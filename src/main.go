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
import (
	"encoding/base64"
	"math/big"

	"github.com/erh/gonmea/common"
)

//export enforce_binding
func enforce_binding() {}

func main() {}

//export res_9_nclose
func res_9_nclose() {}

//export res_9_ninit
func res_9_ninit() {}

//export res_9_nsearch
func res_9_nsearch() {}

//export parse_data
func parse_data(data *C.char, length C.int) *C.char {
	byteArr := C.GoBytes(unsafe.Pointer(data), length)

	var dataMap map[string]string
	if err := json.Unmarshal([]byte(byteArr), &dataMap); err != nil {
		in := io.NopCloser(bytes.NewReader(byteArr))
		defer in.Close()

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
			msg, _, err := analyzer.ParseMessage(line)
			
			if err != nil {
				return C.CString(fmt.Sprintf("Error: %v", err))
			}
			md, err := json.MarshalIndent(msg, "", "  ")
			if err != nil {
				return C.CString(fmt.Sprintf("Error: %v", err))
			}
			return C.CString(string(md))
		}
	}

	for pgnSrcStr, pgnData := range dataMap {
		pgnSrcPair := strings.SplitN(pgnSrcStr, "-", 2)
		if len(pgnSrcPair) != 2 {
			return C.CString("Error: expected hex-encoded-PGN-src pair separated by hyphen")
		}
		pgnInt := &big.Int{}
		pgnInt, ok := pgnInt.SetString(pgnSrcPair[0], 16)
		if !ok {
			return C.CString("Error: error decoding PGN hex")
		}
		srcInt := &big.Int{}
		srcInt, ok = srcInt.SetString(pgnSrcPair[1], 16)
		if !ok {
			return C.CString("Error: error decoding Src hex")
		}

		decoded, err := base64.StdEncoding.DecodeString(pgnData)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: error decoding base64 data: %v", err))
		}

		rawMsg := common.RawMessage{
			PGN:  uint32(pgnInt.Uint64()),
			Src:  uint8(srcInt.Uint64()),
			Len:  uint8(len(decoded)),
			Data: decoded,
		}
		msg, err := analyzer.ConvertRawMessage(&rawMsg)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: error converting message: %v", err))
		}
		md, err := json.MarshalIndent(msg, "", "  ")
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		return C.CString(string(md))
	}
	return nil

}