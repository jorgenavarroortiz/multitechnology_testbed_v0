/*
 * Namf_EventExposure
 *
 * AMF Event Exposure Service
 *
 * API version: 1.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package EventExposure

import (
	"github.com/gin-gonic/gin"
	"free5gc/lib/openapi/models"
	"free5gc/src/amf/amf_context"
	"free5gc/src/amf/amf_producer"
	"log"
	"net/http"
	"time"
)

// CreateSubscription - Namf_EventExposure Subscribe service Operation
func CreateSubscription(c *gin.Context) {

	var createEventSubscription models.AmfCreateEventSubscription

	if err := c.ShouldBindJSON(&createEventSubscription); err != nil {
		log.Panic(err.Error())
	}
	self := amf_context.AMF_Self()
	res, problem := amf_producer.CreateAMFEventSubscription(self, createEventSubscription, time.Now().UTC())
	if problem.Cause != "" {
		c.JSON(int(problem.Status), problem)
	} else {
		c.JSON(http.StatusCreated, res)
	}
}
