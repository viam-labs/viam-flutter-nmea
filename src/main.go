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

	"github.com/erh/viamboat/gonmea/analyzer"
)
import (
	"encoding/base64"
	"encoding/binary"
	"math/big"
	"time"

	"github.com/erh/viamboat/gonmea/common"
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
			// TODO: Validate .ParseMessage(line) replaced by .ParseTextMessage(string(line))
			msg, _, err := analyzer.ParseTextMessage(string(line))

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
			return C.CString("Error: error decoding src hex")
		}

		decoded, err := base64.StdEncoding.DecodeString(pgnData)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: error decoding base64 data %v", err))
		}
		pgn := binary.LittleEndian.Uint32(decoded[0:4])
		// ignore pad
		tvS := binary.LittleEndian.Uint64(decoded[8:16])
		tvUsec := binary.LittleEndian.Uint64(decoded[16:24])
		length := binary.LittleEndian.Uint16(decoded[24:26])
		destination := binary.LittleEndian.Uint16(decoded[26:28])
		source := binary.LittleEndian.Uint16(decoded[28:30])
		priority := binary.LittleEndian.Uint16(decoded[30:32])
		data := decoded[32:]

		if length != uint16(len(decoded[32:])) {
			return C.CString(fmt.Sprintf("Error: bad length check %d!=%d", length, len(decoded[32:])))
		}
		decoded = decoded[32:]

		rawMsg := common.RawMessage{
			Timestamp: time.Unix(int64(tvS), int64(tvUsec*1e3)),
			Prio:      uint8(priority),
			PGN:       pgn,
			Dst:       uint8(destination),
			Src:       uint8(source),
			Len:       uint8(length),
			Data:      data,
		}
		// TODO: Newly added insufficient data return value handling
		msg, _, err := analyzer.ConvertRawMessage(&rawMsg)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: error converting message %v", err))
		}
		md, err := json.MarshalIndent(msg, "", "  ")
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		return C.CString(string(md))
	}
	return nil

}
