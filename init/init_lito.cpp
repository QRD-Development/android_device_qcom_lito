/*
 * Copyright (C) 2022-2023 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android-base/strings.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

using android::base::GetProperty;
using android::base::ReadFileToString;
using android::base::Split;
using android::base::Trim;

/*
 * SetProperty does not allow updating read only properties and as a result
 * does not work for our use case. Write "OverrideProperty" to do practically
 * the same thing as "SetProperty" without this restriction.
 */
void OverrideProperty(const char* name, const char* value) {
    size_t valuelen = strlen(value);

    prop_info* pi = (prop_info*)__system_property_find(name);
    if (pi != nullptr) {
        __system_property_update(pi, value, valuelen);
    } else {
        __system_property_add(name, strlen(name), value, valuelen);
    }
}

/*
 * Only for read-only properties. Properties that can be wrote to more
 * than once should be set in a typical init script (e.g. init.oplus.hw.rc)
 * after the original property has been set.
 */
void vendor_load_properties() {
    if (std::string content; ReadFileToString("/sys/devices/soc0/soc_id", &content)) {
        OverrideProperty("ro.vendor.qti.soc_id", Split(Trim(content), "\t").back().c_str());
    }

    auto soc_version = std::stoi(GetProperty("ro.vendor.qti.soc_id", "0"));

    switch (soc_version) {
        case 400: // SM7250
            OverrideProperty("ro.vendor.qti.soc_model", "SM7250");
            break;
        case 434: // SM6350
            OverrideProperty("ro.vendor.qti.soc_model", "SM6350");
            break;
        case 459: // SM7225
            OverrideProperty("ro.vendor.qti.soc_model", "SM7225");
            break;
        default:
            LOG(ERROR) << "Unexpected Soc version: " << soc_version;
    }
}
