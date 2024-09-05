# flavoring

A new Flutter project.

## Add flavor in android
add following code inside the build.gradle file of app

```groovy
flavorDimensions "default"

productFlavors {
    prod {
        resValue "string", "app_name", "Flavor"
        dimension "default"
    }

    qa {
        resValue "string", "app_name", "Flavor [QA]"
        dimension "default"
        applicationIdSuffix ".qa"
    }

    dev {
        resValue "string", "app_name", "Flavor [DEV]"
        dimension "default"
        applicationIdSuffix ".dev"
    }
}
```

- Change the `android:label` to `@string/app_name` from `AndroidManifest.xml` file 
- Add flavor specif folder inside the src director of android
- Generate `Image Assets` for each newly created folder to show flavor specific app logo


## IOS
__TODO__


## Flutter
Access the flavor name using `appFlavor` global constant value.
