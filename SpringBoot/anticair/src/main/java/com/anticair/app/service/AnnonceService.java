package com.anticair.app.service;

import com.anticair.app.dto.AnnonceDTO;
import com.anticair.app.entity.Annonce;
import com.anticair.app.exception.ResourceNotFoundException;
import com.anticair.app.repository.AnnonceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnnonceService {
    private final AnnonceRepository annonceRepository;

    public List<AnnonceDTO> getAllAnnonces() {
        return annonceRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }


    public AnnonceDTO getAnnonceById(Long id) {
        return annonceRepository.findById(id)
                .map(this::convertToDTO)
                .orElseThrow(() -> new ResourceNotFoundException("Annonce not found with id: " + id));
    }

    @Transactional
    public AnnonceDTO createAnnonce(AnnonceDTO annonceDTO) {

        Annonce annonce = convertToEntity(annonceDTO);

        Annonce savedAnnonce = annonceRepository.save(annonce);
        return convertToDTO(savedAnnonce);
    }

    @Transactional
    public AnnonceDTO updateAnnonce(Long id, AnnonceDTO annonceDTO) {
        Annonce existingAnnonce = annonceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Annonce not found with id: " + id));

        existingAnnonce.setTitre(annonceDTO.getTitre());
        existingAnnonce.setDescription(annonceDTO.getDescription());
        existingAnnonce.setPrix(annonceDTO.getPrix());

        if (annonceDTO.getCategory() != null) {
            existingAnnonce.setCategory(annonceDTO.getCategory());
        }
        if (annonceDTO.getStatus() != null) {
            existingAnnonce.setStatus(annonceDTO.getStatus());
        }
        if (annonceDTO.getImageUrl() != null) {
            existingAnnonce.setImageUrl(annonceDTO.getImageUrl());
        }

        return convertToDTO(annonceRepository.save(existingAnnonce));
    }

    @Transactional
    public void deleteAnnonce(Long id) {
        if (!annonceRepository.existsById(id)) {
            throw new ResourceNotFoundException("Annonce not found with id: " + id);
        }
        annonceRepository.deleteById(id);
    }

    private AnnonceDTO convertToDTO(Annonce annonce) {
        AnnonceDTO dto = new AnnonceDTO();
        dto.setId(annonce.getId());
        dto.setTitre(annonce.getTitre());
        dto.setDescription(annonce.getDescription());
        dto.setPrix(annonce.getPrix());
        dto.setImageUrl(annonce.getImageUrl());
        dto.setCategory(annonce.getCategory());
        dto.setStatus(annonce.getStatus());
        return dto;
    }

    private Annonce convertToEntity(AnnonceDTO dto) {
        Annonce annonce = new Annonce();
        if (dto.getId() != null) {
            annonce.setId(dto.getId());
        }
        annonce.setTitre(dto.getTitre());
        annonce.setDescription(dto.getDescription());
        annonce.setPrix(dto.getPrix());
        annonce.setImageUrl(dto.getImageUrl());
        annonce.setCategory(dto.getCategory());
        annonce.setStatus(dto.getStatus());
        return annonce;
    }
}