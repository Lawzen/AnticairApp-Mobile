package com.anticair.app.controller;

import com.anticair.app.dto.AnnonceDTO;
import com.anticair.app.service.AnnonceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/annonces")
@RequiredArgsConstructor
public class AnnonceController {
    private final AnnonceService annonceService;

    @GetMapping
    public ResponseEntity<?> getAllAnnonces() {
        return ResponseEntity.ok(annonceService.getAllAnnonces());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getAnnonceById(@PathVariable Long id) {
        return ResponseEntity.ok(annonceService.getAnnonceById(id));
    }

    @PostMapping
    public ResponseEntity<?> createAnnonce(@RequestBody AnnonceDTO annonceDTO) {
        return ResponseEntity.ok(annonceService.createAnnonce(annonceDTO));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAnnonce(@PathVariable Long id, @RequestBody AnnonceDTO annonceDTO) {
        return ResponseEntity.ok(annonceService.updateAnnonce(id, annonceDTO));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAnnonce(@PathVariable Long id) {
        annonceService.deleteAnnonce(id);
        return ResponseEntity.ok().build();
    }
}