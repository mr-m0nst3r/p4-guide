// Copyright 2024 Andy Fingerhut
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#ifndef _SIRIUS_INBOUND_P4_
#define _SIRIUS_INBOUND_P4_

#include "dash_headers.p4"
#include "dash_service_tunnel.p4"
#include "dash_acl.p4"
#include "dash_conntrack.p4"

control inbound(inout headers_t hdr,
                inout metadata_t meta)
{
    apply {
#ifdef STATEFUL_P4
            ConntrackIn.apply(0);
#endif /* STATEFUL_P4 */
#ifdef PNA_CONNTRACK
        ConntrackIn.apply(hdr, meta);

        if (meta.encap_data.original_overlay_sip != 0) {
            service_tunnel_decode(hdr,
                                  meta.encap_data.original_overlay_sip,
                                  meta.encap_data.original_overlay_dip);
        }
#endif // PNA_CONNTRACK

        /* ACL */
        if (!meta.conntrack_data.allow_in) {
            acl.apply(hdr, meta);
        }

#ifdef STATEFUL_P4
            ConntrackOut.apply(1);
#endif /* STATEFUL_P4 */
#ifdef PNA_CONNTRACK
        ConntrackOut.apply(hdr, meta);
#endif //PNA_CONNTRACK

        tunnel_encap(hdr,
                     meta,
                     meta.encap_data.overlay_dmac,
                     meta.encap_data.underlay_dmac,
                     meta.encap_data.underlay_smac,
                     meta.encap_data.underlay_dip,
                     meta.encap_data.underlay_sip,
                     dash_encapsulation_t.VXLAN,
                     meta.encap_data.vni);
    }
}

#endif /* _SIRIUS_INBOUND_P4_ */
