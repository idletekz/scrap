If Helm release contains Istio custom resources like ServiceEntry and VirtualService, and we remove the Istio CRDs first, those kinds stop existing in the Kubernetes API. Kubernetes also deletes the custom objects for a CRD when that CRD is deleted.

That creates two problems for Helm:

Upgrade fail because Helm/Kubernetes can no longer recognize networking.istio.io/* kinds such as ServiceEntry and VirtualService if the CRDs are gone. Helm’s CRD guidance also says the CRD must exist before resources using it can be managed.

Uninstall also fail or become incomplete because the release metadata still contains those Istio resources, but the API server no longer knows those kinds. Helm also explicitly does cannot manage CRD upgrade/delete lifecycle for you.

So the safe rule is:

Do not delete Istio CRDs before uninstalling or refactoring the Helm release that owns Istio CRs.

First remove the ServiceEntry / VirtualService objects from the chart and run a Helm upgrade, or helm uninstall the release first.

Only after those Istio custom resources are gone should you remove the Istio CRDs.

If you already deleted the CRDs, the common recovery path is to reinstall the matching Istio CRDs, then run helm upgrade or helm uninstall again so Helm can reconcile/delete those resources properly. In some cases, people also repair Helm’s stored manifest metadata, but reinstalling the CRDs is the cleaner fix.
