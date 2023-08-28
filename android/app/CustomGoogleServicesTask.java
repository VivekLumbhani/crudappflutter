package com.your.package.name;

import com.google.gms.googleservices.GoogleServicesTask;
import org.gradle.api.file.DirectoryProperty;
import org.gradle.api.provider.Property;
import org.gradle.api.tasks.Input;
import org.gradle.api.tasks.InputDirectory;
import org.gradle.api.tasks.InputFile;
import org.gradle.api.tasks.Optional;

public class CustomGoogleServicesTask extends GoogleServicesTask {
    @InputDirectory
    @Optional
    @Override
    public DirectoryProperty getIntermediateDir() {
        return super.getIntermediateDir();
    }

    @Input
    @Override
    public Property<String> getPackageName() {
        return super.getPackageName();
    }

    @InputFile
    @Optional
    @Override
    public Property<File> getQuickstartFile() {
        return super.getQuickstartFile();
    }

    @Input
    @Override
    public Property<String> getSearchedLocation() {
        return super.getSearchedLocation();
    }
}
