/*
 * NSSF NSSAI Availability
 *
 * NSSF NSSAI Availability Service
 *
 * API version: 1.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package NSSAIAvailability

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"free5gc/lib/http_wrapper"
	. "free5gc/lib/openapi/models"
	"free5gc/src/nssf/nssf_handler"
	"free5gc/src/nssf/nssf_handler/nssf_message"
	"free5gc/src/nssf/plugin"
	"free5gc/src/nssf/util"
)

func ApiNfInstanceIdDocumentDelete(c *gin.Context) {
	var request interface{}
	req := http_wrapper.NewRequest(c.Request, request)
	req.Params["nfId"] = c.Param("nfId")

	message := nssf_message.NewMessage(nssf_message.NSSAIAvailabilityDelete, req)

	nssf_handler.SendMessage(message)
	rsp := <-message.ResponseChan

	httpResponse := rsp.HttpResponse
	c.JSON(httpResponse.Status, httpResponse.Body)
}

func ApiNfInstanceIdDocumentPatch(c *gin.Context) {
	var request plugin.PatchDocument
	err := c.ShouldBindJSON(&request)
	if err != nil {
		problemDetail := "[Request Body] " + err.Error()
		d := ProblemDetails{
			Title:  util.MALFORMED_REQUEST,
			Status: http.StatusBadRequest,
			Detail: problemDetail,
		}
		c.JSON(http.StatusBadRequest, d)
		return
	}
	req := http_wrapper.NewRequest(c.Request, request)
	req.Params["nfId"] = c.Param("nfId")

	message := nssf_message.NewMessage(nssf_message.NSSAIAvailabilityPatch, req)

	nssf_handler.SendMessage(message)
	rsp := <-message.ResponseChan

	httpResponse := rsp.HttpResponse
	c.JSON(httpResponse.Status, httpResponse.Body)
}

func ApiNfInstanceIdDocumentPut(c *gin.Context) {
	var request NssaiAvailabilityInfo
	err := c.ShouldBindJSON(&request)
	if err != nil {
		problemDetail := "[Request Body] " + err.Error()
		d := ProblemDetails{
			Title:  util.MALFORMED_REQUEST,
			Status: http.StatusBadRequest,
			Detail: problemDetail,
		}
		c.JSON(http.StatusBadRequest, d)
		return
	}
	req := http_wrapper.NewRequest(c.Request, request)
	req.Params["nfId"] = c.Param("nfId")

	message := nssf_message.NewMessage(nssf_message.NSSAIAvailabilityPut, req)

	nssf_handler.SendMessage(message)
	rsp := <-message.ResponseChan

	httpResponse := rsp.HttpResponse
	c.JSON(httpResponse.Status, httpResponse.Body)
}
