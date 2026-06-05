package kr.co.jihun.guisample.dto;

/**
 * 파일 업로드 → 청킹 → 임베딩 → pgvector 적재 결과 응답 DTO.
 * 성공/실패 모두 HTTP 200 + 이 shape 으로 통일하여 프론트 분기를 단순화한다.
 *
 * @param success    처리 성공 여부
 * @param source     저장된 source 값(에코백)
 * @param chunkCount vector_store 에 적재된 청크 수
 * @param message    사용자 표시용 메시지(성공/실패 사유)
 */
public record EmbeddingResponse(
        boolean success,
        String source,
        int chunkCount,
        String message
)
{
}
