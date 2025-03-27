/******************************************************************************
* File Name:   cy_ota_config.h
*
* Description: This file contains the OTA middleware level configuration macros.
*
* Related Document: See README.md
*
*
*******************************************************************************
* Copyright 2020-2025, Cypress Semiconductor Corporation (an Infineon company) or
* an affiliate of Cypress Semiconductor Corporation.  All rights reserved.
*
* This software, including source code, documentation and related
* materials ("Software") is owned by Cypress Semiconductor Corporation
* or one of its affiliates ("Cypress") and is protected by and subject to
* worldwide patent protection (United States and foreign),
* United States copyright laws and international treaty provisions.
* Therefore, you may use this Software only as provided in the license
* agreement accompanying the software package from which you
* obtained this Software ("EULA").
* If no EULA applies, Cypress hereby grants you a personal, non-exclusive,
* non-transferable license to copy, modify, and compile the Software
* source code solely for use in connection with Cypress's
* integrated circuit products.  Any reproduction, modification, translation,
* compilation, or representation of this Software except as specified
* above is prohibited without the express written permission of Cypress.
*
* Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, NONINFRINGEMENT, IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Cypress
* reserves the right to make changes to the Software without notice. Cypress
* does not assume any liability arising out of the application or use of the
* Software or any product or circuit described in the Software. Cypress does
* not authorize its products for use in any products where a malfunction or
* failure of the Cypress product may reasonably be expected to result in
* significant property damage, injury or death ("High Risk Product"). By
* including Cypress's product in a High Risk Product, the manufacturer
* of such system or application assumes all risk of such use and in doing
* so agrees to indemnify Cypress against all liability.
*******************************************************************************/

#ifndef CY_OTA_CONFIG_H__
#define CY_OTA_CONFIG_H__

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \addtogroup group_ota_config
 * \{
 */
/**
 * @brief Initial time for checking for OTA updates
 *
 * This is used to start the timer for the initial OTA update check after calling cy_ota_agent_start().
 */
#define CY_OTA_INITIAL_CHECK_SECS           (10)            /* 10 seconds */

/**
 * @brief Next time for checking for OTA updates
 *
 * This is used to re-start the timer after an OTA update check in the OTA Agent.
 */
#define CY_OTA_NEXT_CHECK_INTERVAL_SECS     (10)            /* 10 seconds between checks */

/**
 * @brief Retry time which checking for OTA updates
 *
 * This is used to re-start the timer after failing to contact the server during an OTA update check.
 */
#define CY_OTA_RETRY_INTERVAL_SECS          (5)             /* 5 seconds between retries after an error */

/**
 * @brief Length of time to check for downloads
 *
 * OTA Agent wakes up, connects to server, and waits this much time before disconnecting.
 * This allows the OTA Agent to be inactive for long periods of time, only checking for short periods.
 * Use 0x00 to continue checking once started.
 */
#define CY_OTA_CHECK_TIME_SECS              (10 * 60)       /* 10 minutes */

/**
 * @brief Expected maximum download time between each OTA packet arrival
 *
 * This is used check that the download occurs in a reasonable time frame.
 * Set to 0 to disable this check.
 */
#define CY_OTA_PACKET_INTERVAL_SECS         (0)             /* default disabled */

/**
 * @brief Length of time to check for getting Job Document
 *
 * OTA Agent wakes up, connects to broker/server, and waits this much time before disconnecting.
 * This allows the OTA Agent to be inactive for long periods of time, only checking for short periods.
 * Use 0x00 to continue checking once started.
 */
#define CY_OTA_JOB_CHECK_TIME_SECS           (30)               /* 30 seconds */

/**
 * @brief Length of time to check for getting OTA Image data
 *
 * After getting the Job (or during a Direct download), this is the amount of time we wait before
 * deciding we are not going to get the download.
 * Use 0x00 to disable.
 */
#define CY_OTA_DATA_CHECK_TIME_SECS          (5 * 60)           /* 5 minutes */
/**
 * @brief Number of OTA session retries
 *
 * Retry count for overall OTA session attempts
 */
#define CY_OTA_RETRIES                      (3)             /* retry entire process 3 times */

/**
 * @brief Number of retries when attempting to contact the server
 *
 * This is used to determine # retries when connecting to the server during an OTA update check.
 */
#define CY_OTA_CONNECT_RETRIES              (3)             /* 3 server connect retries  */

/**
 * @brief Number of OTA download retries
 *
 * Retry count for attempts at downloading the OTA Image
 */
#define CY_OTA_MAX_DOWNLOAD_TRIES           (3)             /* 3 download OTA Image retries */

/**
 * @brief HTTP timeout for receiving messages
 *
 */
#define CY_OTA_HTTP_TIMEOUT_RECEIVE         (2000)          /* 2 second receive timeout. */

/**
 * @brief HTTP timeout for sending messages
 *
 */
#define CY_OTA_HTTP_TIMEOUT_SEND            (2000)          /* 2 second send timeout. */
/**********************************************************************
 * Message Defines
 **********************************************************************/

/**
 * @brief Last part of the topic to subscribe
 *
 * Topic for Device to send message to Publisher:
 *  "COMPANY_TOPIC_PREPEND / BOARD_NAME / PUBLISHER_LISTEN_TOPIC"
 *  The combined topic needs to match the Publisher's subscribe topic
 *
 * Override in cy_ota_config.h
 */
#define PUBLISHER_LISTEN_TOPIC              "publish_notify"

/**
 * @brief First part of the topic to subscribe / publish
 *
 * Topic for Device to send message to Publisher:
 *  "COMPANY_TOPIC_PREPEND / BOARD_NAME / PUBLISHER_LISTEN_TOPIC"
 */
#define COMPANY_TOPIC_PREPEND               "MyUniqueTopic"

/**
 * @brief End of Topic to send message to Publisher for Direct download
 */
#define PUBLISHER_DIRECT_TOPIC              "OTAImage"

/**
 * @brief Update Successful message
 *
 * Used with sprintf() to create RESULT message to Broker / Server
 */
#define CY_OTA_RESULT_SUCCESS               "Success"

/**
* @brief Update Failure message
*
* Used with sprintf() to create RESULT message to Broker / Server
*/
#define CY_OTA_RESULT_FAILURE               "Failure"

/**
 * @brief Device message to Publisher to ask about updates
 * Used with sprintf() to insert the current version and UniqueTopicName at runtime.
 * Override if desired by defining in cy_ota_config.h.
 */
#define CY_OTA_SUBSCRIBE_UPDATES_AVAIL \
"{\
\"Message\":\"Update Availability\", \
\"Manufacturer\": \"Infineon\", \
\"ManufacturerID\": \"ABCD123\", \
\"ProductID\": \"EFGH456\", \
\"SerialNumber\": \"ABC213450001\", \
\"BoardName\": \"CY8CPROTO_062_4343W\", \
\"Version\": \"%d.%d.%d\", \
\"UniqueTopicName\": \"%s\"\
}"

/**
 * @brief Device message to Publisher to ask for a download
 * *
 * Used with sprintf() to insert the current version and UniqueTopicName at runtime.
 * Override if desired by defining in cy_ota_config.h.
 */
#define CY_OTA_DOWNLOAD_REQUEST \
"{\
\"Message\":\"Request Update\", \
\"Manufacturer\": \"Infineon\", \
\"ManufacturerID\": \"ABCD123\", \
\"ProductID\": \"EFGH456\", \
\"SerialNumber\": \"ABC213450001\", \
\"BoardName\": \"CY8CPROTO_062_4343W\", \
\"Version\": \"%d.%d.%d\", \
\"UniqueTopicName\": \"%s\"\
}"

/**
 * @brief Device message to Publisher to ask for a download
 * *
 * Used with sprintf() to insert the current version and UniqueTopicName at runtime.
 * Override if desired by defining in cy_ota_config.h.
 */
#define CY_OTA_DOWNLOAD_DIRECT_REQUEST \
"{\
\"Message\":\"Send Direct Update\", \
\"Manufacturer\": \"Infineon\", \
\"ManufacturerID\": \"ABCD123\", \
\"ProductID\": \"EFGH456\", \
\"SerialNumber\": \"ABC213450001\", \
\"BoardName\": \"CY8CPROTO_062_4343W\", \
\"Version\": \"%d.%d.%d\" \
}"
/**
 * @brief Device JSON doc to respond to HTTP Server
 *
 * Used with sprintf() to create the JSON message
 * Override if desired by defining in cy_ota_config.h.
 */
#define CY_OTA_HTTP_RESULT_JSON \
"{\
\"Message\":\"%s\", \
\"File\":\"%s\" \
}"

/**
 * @brief HTTP GET template
 *
 * Used with sprintf() to create the GET request for HTTP server
 */
#ifndef CY_OTA_HTTP_GET_TEMPLATE
#define CY_OTA_HTTP_GET_TEMPLATE \
    "GET %s HTTP/1.1\r\n" \
    "Host: %s:%d \r\n" \
    "\r\n"
#endif

/**
 * @brief HTTP POST template
 *
 * Used with sprintf() to create the POST message for HTTP server
 */
#ifndef CY_OTA_HTTP_POST_TEMPLATE
#define CY_OTA_HTTP_POST_TEMPLATE \
    "POST %s HTTP/1.1\r\n" \
    "Content-Length:%ld \r\n" \
    "\r\n%s"
#endif


/** \} group_ota_config */

#ifdef __cplusplus
    }
#endif

#endif /* CY_OTA_CONFIG_H__ */

/** \} group_cy_ota */
